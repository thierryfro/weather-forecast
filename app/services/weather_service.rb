# frozen_string_literal: true

# Service class for fetching weather data from external API
class WeatherService
  include HTTParty

  base_uri ENV.fetch('OPENWEATHER_BASE_URL', 'https://api.openweathermap.org/data/2.5')
  default_params appid: ENV.fetch('OPENWEATHER_API_KEY', 'test_key')

  def self.current_weather(zip_code)
    start_time = Time.current
    Rails.logger.info("WeatherService: Fetching current weather for zip_code=#{zip_code}")
    
    response = get('/weather', query: { zip: zip_code, units: 'metric' })
    
    if response.success?
      Rails.logger.info("WeatherService: Successfully fetched weather for zip_code=#{zip_code}, response_time=#{Time.current - start_time}ms")
      parse_weather_response(response.parsed_response)
    else
      Rails.logger.error("WeatherService: API error for zip_code=#{zip_code}, status=#{response.code}, message=#{response.dig('message')}")
      handle_api_error(response)
    end
  rescue StandardError => e
    Rails.logger.error("WeatherService: Unexpected error for zip_code=#{zip_code}, error=#{e.class.name}, message=#{e.message}")
    handle_error(e)
  end

  def self.forecast(zip_code)
    start_time = Time.current
    Rails.logger.info("WeatherService: Fetching forecast for zip_code=#{zip_code}")
    
    response = get('/forecast', query: { zip: zip_code, units: 'metric' })
    
    if response.success?
      Rails.logger.info("WeatherService: Successfully fetched forecast for zip_code=#{zip_code}, response_time=#{Time.current - start_time}ms")
      parse_forecast_response(response.parsed_response)
    else
      Rails.logger.error("WeatherService: API error for zip_code=#{zip_code}, status=#{response.code}, message=#{response.dig('message')}")
      handle_api_error(response)
    end
  rescue StandardError => e
    Rails.logger.error("WeatherService: Unexpected error for zip_code=#{zip_code}, error=#{e.class.name}, message=#{e.message}")
    handle_error(e)
  end

  private

  # Parses the current weather API response into a standardized format
  # @param response [Hash] Raw API response
  # @return [Hash] Standardized weather data
  def self.parse_weather_response(response)
    {
      current: {
        temperature: response.dig('main', 'temp'),
        feels_like: response.dig('main', 'feels_like'),
        humidity: response.dig('main', 'humidity'),
        pressure: response.dig('main', 'pressure'),
        description: response.dig('weather', 0, 'description'),
        icon: response.dig('weather', 0, 'icon')
      },
      location: {
        name: response['name'],
        country: response.dig('sys', 'country'),
        zip_code: response['zip_code']
      },
      timestamp: Time.current
    }
  end

  # Parses the forecast API response into a standardized format
  # @param response [Hash] Raw API response
  # @return [Hash] Standardized forecast data
  def self.parse_forecast_response(response)
    {
      location: {
        name: response['city']['name'],
        country: response.dig('city', 'country'),
        zip_code: response['zip_code']
      },
      forecast: response['list'].map do |item|
        {
          datetime: Time.at(item['dt']),
          temperature: item.dig('main', 'temp'),
          feels_like: item.dig('main', 'feels_like'),
          humidity: item.dig('main', 'humidity'),
          pressure: item.dig('main', 'pressure'),
          description: item.dig('weather', 0, 'description'),
          icon: item.dig('weather', 0, 'icon')
        }
      end,
      timestamp: Time.current
    }
  end

  # Handles API errors and returns standardized error format
  # @param response [HTTParty::Response] API response
  # @return [Hash] Error information
  def self.handle_api_error(response)
    {
      error: true,
      message: response.dig('message') || 'Weather API error',
      code: response.code,
      timestamp: Time.current
    }
  end

  # Handles general errors and returns standardized error format
  # @param error [StandardError] The error that occurred
  # @return [Hash] Error information
  def self.handle_error(error)
    {
      error: true,
      message: error.message,
      code: 500,
      timestamp: Time.current
    }
  end
end
