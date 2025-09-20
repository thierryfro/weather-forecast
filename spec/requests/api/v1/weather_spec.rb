# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Weather API', type: :request do
  let(:zip_code) { '10001' }
  let(:weather_data) do
    {
      current: { temperature: 20.5, description: 'clear sky' },
      location: { name: 'New York', country: 'US' },
      timestamp: Time.current
    }
  end

  describe 'GET /api/v1/weather/current/:zip_code' do
    before do
      allow(WeatherForecastService).to receive(:current_weather)
        .with(zip_code).and_return(weather_data)
    end

    it 'returns current weather data' do
      get "/api/v1/weather/current/#{zip_code}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'success' => true,
        'message' => 'Current weather data retrieved successfully',
        'data' => hash_including(
          'current' => hash_including('temperature' => 20.5),
          'location' => hash_including('name' => 'New York')
        )
      )
    end
  end

  describe 'GET /api/v1/weather/forecast/:zip_code' do
    let(:forecast_data) do
      {
        location: { name: 'New York', country: 'US' },
        forecast: [
          { datetime: Time.current, temperature: 20.5, description: 'clear sky' }
        ],
        timestamp: Time.current
      }
    end

    before do
      allow(WeatherForecastService).to receive(:forecast)
        .with(zip_code).and_return(forecast_data)
    end

    it 'returns forecast data' do
      get "/api/v1/weather/forecast/#{zip_code}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'success' => true,
        'message' => 'Forecast data retrieved successfully',
        'data' => hash_including(
          'location' => hash_including('name' => 'New York'),
          'forecast' => array_including(
            hash_including('temperature' => 20.5)
          )
        )
      )
    end
  end

  describe 'GET /api/v1/weather/complete/:zip_code' do
    let(:complete_data) do
      {
        current: weather_data,
        forecast: {
          location: { name: 'New York', country: 'US' },
          forecast: [{ datetime: Time.current, temperature: 20.5 }],
          timestamp: Time.current
        },
        location: { name: 'New York', country: 'US' },
        timestamp: Time.current
      }
    end

    before do
      allow(WeatherForecastService).to receive(:complete_forecast)
        .with(zip_code).and_return(complete_data)
    end

    it 'returns complete weather data' do
      get "/api/v1/weather/complete/#{zip_code}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'success' => true,
        'message' => 'Complete weather data retrieved successfully',
        'data' => hash_including(
          'current' => hash_including('current'),
          'forecast' => hash_including('forecast'),
          'location' => hash_including('name' => 'New York')
        )
      )
    end
  end

  describe 'GET /api/v1/weather/cache_status/:zip_code' do
    let(:status_data) do
      {
        current_cached: true,
        forecast_cached: false,
        zip_code: zip_code,
        timestamp: Time.current
      }
    end

    before do
      allow(WeatherForecastService).to receive(:cache_status)
        .with(zip_code).and_return(status_data)
    end

    it 'returns cache status' do
      get "/api/v1/weather/cache_status/#{zip_code}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'success' => true,
        'message' => 'Cache status retrieved successfully',
        'data' => hash_including(
          'current_cached' => true,
          'forecast_cached' => false,
          'zip_code' => zip_code
        )
      )
    end
  end

  describe 'DELETE /api/v1/weather/cache/:zip_code' do
    before do
      allow(WeatherForecastService).to receive(:clear_cache)
        .with(zip_code).and_return(true)
    end

    it 'clears cache successfully' do
      delete "/api/v1/weather/cache/#{zip_code}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'success' => true,
        'message' => 'Cache cleared successfully',
        'data' => hash_including('zip_code' => zip_code)
      )
    end
  end

  describe 'error handling' do
    it 'returns 400 for invalid zip code' do
      get '/api/v1/weather/current/invalid'

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include(
        'success' => false,
        'error' => 'Invalid zip code format'
      )
    end

    it 'returns 400 for blank zip code' do
      get '/api/v1/weather/current/'

      expect(response).to have_http_status(:not_found)
    end
  end
end
