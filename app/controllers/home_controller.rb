# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @zip_code = params[:zip_code]
    @weather_data = nil
    @error_message = nil

    if @zip_code.present?
      begin
        @weather_data = WeatherForecastService.complete_forecast(@zip_code)
        @cache_status = WeatherForecastService.cache_status(@zip_code)
      rescue ArgumentError => e
        @error_message = e.message
      rescue StandardError => e
        @error_message = "An error occurred: #{e.message}"
      end
    end
  end

  def search
    zip_code = params[:zip_code]
    
    if zip_code.blank?
      redirect_to root_path, alert: 'Please enter a zip code'
      return
    end

    redirect_to root_path(zip_code: zip_code)
  end

  def clear_cache
    zip_code = params[:zip_code]
    
    if zip_code.present?
      WeatherForecastService.clear_cache(zip_code)
      redirect_to root_path(zip_code: zip_code), notice: 'Cache cleared successfully'
    else
      redirect_to root_path, alert: 'Invalid zip code'
    end
  end
end
