# frozen_string_literal: true

# Main service class for weather forecast operations
# Implements Facade pattern to provide a simple interface
class WeatherForecastService
  def self.current_weather(zip_code)
    validate_zip_code!(zip_code)
    
    cached_data = CacheService.get(zip_code, :current)
    return cached_data if cached_data

    weather_data = WeatherService.current_weather(zip_code)
    CacheService.set(zip_code, weather_data, :current) unless weather_data[:error]
    
    weather_data
  end

  def self.forecast(zip_code)
    validate_zip_code!(zip_code)
    
    cached_data = CacheService.get(zip_code, :forecast)
    return cached_data if cached_data

    forecast_data = WeatherService.forecast(zip_code)
    CacheService.set(zip_code, forecast_data, :forecast) unless forecast_data[:error]
    
    forecast_data
  end

  def self.complete_forecast(zip_code)
    validate_zip_code!(zip_code)
    
    current = current_weather(zip_code)
    forecast = forecast(zip_code)
    
    {
      current: current,
      forecast: forecast,
      location: current[:location] || forecast[:location],
      timestamp: Time.current
    }
  end

  def self.clear_cache(zip_code)
    validate_zip_code!(zip_code)
    CacheService.clear(zip_code)
  end

  def self.cache_status(zip_code)
    validate_zip_code!(zip_code)
    
    {
      current_cached: CacheService.exists?(zip_code, :current),
      forecast_cached: CacheService.exists?(zip_code, :forecast),
      zip_code: zip_code,
      timestamp: Time.current
    }
  end

  private

  def self.validate_zip_code!(zip_code)
    raise ArgumentError, 'Zip code cannot be blank' if zip_code.blank?
    raise ArgumentError, 'Invalid zip code format' unless valid_zip_code?(zip_code)
  end

  # Basic validation - can be extended for different countries
  def self.valid_zip_code?(zip_code)
    zip_code.match?(/\A\d{5}(-\d{4})?\z/) || zip_code.match?(/\A[A-Z]\d[A-Z] \d[A-Z]\d\z/)
  end
end
