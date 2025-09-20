# frozen_string_literal: true

# Weather controller for API v1 endpoints
# Implements RESTful design and proper error handling
class Api::V1::WeatherController < ApplicationController
  before_action :validate_zip_code, only: [:current, :forecast, :complete, :cache_status]
  before_action :set_zip_code, only: [:current, :forecast, :complete, :cache_status]

  # GET /api/v1/weather/current/:zip_code
  # Returns current weather data for the specified zip code
  def current
    weather_data = WeatherForecastService.current_weather(@zip_code)
    
    if weather_data[:error]
      render_error(weather_data[:message], weather_data[:code])
    else
      render_success(weather_data, 'Current weather data retrieved successfully')
    end
  end

  # GET /api/v1/weather/forecast/:zip_code
  # Returns extended forecast data for the specified zip code
  def forecast
    forecast_data = WeatherForecastService.forecast(@zip_code)
    
    if forecast_data[:error]
      render_error(forecast_data[:message], forecast_data[:code])
    else
      render_success(forecast_data, 'Forecast data retrieved successfully')
    end
  end

  # GET /api/v1/weather/complete/:zip_code
  # Returns both current weather and forecast data
  def complete
    complete_data = WeatherForecastService.complete_forecast(@zip_code)
    
    if complete_data[:current][:error] || complete_data[:forecast][:error]
      render_error('Failed to retrieve complete weather data', 500)
    else
      render_success(complete_data, 'Complete weather data retrieved successfully')
    end
  end

  # GET /api/v1/weather/cache_status/:zip_code
  # Returns cache status for the specified zip code
  def cache_status
    status_data = WeatherForecastService.cache_status(@zip_code)
    render_success(status_data, 'Cache status retrieved successfully')
  end

  # DELETE /api/v1/weather/cache/:zip_code
  # Clears cache for the specified zip code
  def clear_cache
    @zip_code = params[:zip_code]
    validate_zip_code
    
    if WeatherForecastService.clear_cache(@zip_code)
      render_success({ zip_code: @zip_code }, 'Cache cleared successfully')
    else
      render_error('Failed to clear cache', 500)
    end
  end

  private

  # Validates zip code parameter
  def validate_zip_code
    @zip_code = params[:zip_code]
    
    if @zip_code.blank?
      Rails.logger.warn("API: Missing zip_code parameter from IP=#{request.remote_ip}")
      render_error('Zip code parameter is required', 400)
      return
    end
    
    unless valid_zip_code?(@zip_code)
      Rails.logger.warn("API: Invalid zip_code format=#{@zip_code} from IP=#{request.remote_ip}")
      render_error('Invalid zip code format', 400)
      return
    end
  end

  # Sets zip code from parameters
  def set_zip_code
    @zip_code = params[:zip_code]
  end

  # Checks if zip code format is valid
  # @param zip_code [String] The zip code to validate
  # @return [Boolean] Whether zip code is valid
  def valid_zip_code?(zip_code)
    zip_code.match?(/\A\d{5}(-\d{4})?\z/) || zip_code.match?(/\A[A-Z]\d[A-Z] \d[A-Z]\d\z/)
  end

  # Renders successful response
  # @param data [Hash] Response data
  # @param message [String] Success message
  def render_success(data, message)
    render json: {
      success: true,
      message: message,
      data: data,
      timestamp: Time.current
    }, status: :ok
  end

  # Renders error response
  # @param message [String] Error message
  # @param status_code [Integer] HTTP status code
  def render_error(message, status_code = 500)
    render json: {
      success: false,
      error: message,
      timestamp: Time.current
    }, status: status_code
  end
end
