# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::WeatherController, type: :controller do
  let(:zip_code) { '10001' }
  let(:weather_data) do
    {
      current: { temperature: 20.5, description: 'clear sky' },
      location: { name: 'New York', country: 'US' },
      timestamp: Time.current
    }
  end

  describe 'GET #current' do
    context 'with valid zip code' do
      before do
        allow(WeatherForecastService).to receive(:current_weather)
          .with(zip_code).and_return(weather_data)
      end

      it 'returns current weather data' do
        get :current, params: { zip_code: zip_code }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'data' => hash_including(
            'current' => hash_including('temperature' => 20.5),
            'location' => hash_including('name' => 'New York')
          )
        )
      end
    end

    context 'with invalid zip code' do
      it 'returns error for blank zip code' do
        get :current, params: { zip_code: '' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'error' => 'Zip code parameter is required'
        )
      end

      it 'returns error for invalid format' do
        get :current, params: { zip_code: 'invalid' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'error' => 'Invalid zip code format'
        )
      end
    end

    context 'when service returns error' do
      let(:error_data) { { error: true, message: 'API error', code: 500 } }

      before do
        allow(WeatherForecastService).to receive(:current_weather)
          .with(zip_code).and_return(error_data)
      end

      it 'returns error response' do
        get :current, params: { zip_code: zip_code }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'error' => 'API error'
        )
      end
    end
  end

  describe 'GET #forecast' do
    let(:forecast_data) do
      {
        location: { name: 'New York', country: 'US' },
        forecast: [
          { datetime: Time.current, temperature: 20.5, description: 'clear sky' }
        ],
        timestamp: Time.current
      }
    end

    context 'with valid zip code' do
      before do
        allow(WeatherForecastService).to receive(:forecast)
          .with(zip_code).and_return(forecast_data)
      end

      it 'returns forecast data' do
        get :forecast, params: { zip_code: zip_code }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'data' => hash_including(
            'location' => hash_including('name' => 'New York'),
            'forecast' => array_including(
              hash_including('temperature' => 20.5)
            )
          )
        )
      end
    end
  end

  describe 'GET #complete' do
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

    context 'with valid zip code' do
      before do
        allow(WeatherForecastService).to receive(:complete_forecast)
          .with(zip_code).and_return(complete_data)
      end

      it 'returns complete weather data' do
        get :complete, params: { zip_code: zip_code }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'data' => hash_including(
            'current' => hash_including('current'),
            'forecast' => hash_including('forecast'),
            'location' => hash_including('name' => 'New York')
          )
        )
      end
    end

    context 'when service returns error' do
      let(:error_data) do
        {
          current: { error: true, message: 'API error' },
          forecast: { error: true, message: 'API error' }
        }
      end

      before do
        allow(WeatherForecastService).to receive(:complete_forecast)
          .with(zip_code).and_return(error_data)
      end

      it 'returns error response' do
        get :complete, params: { zip_code: zip_code }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'error' => 'Failed to retrieve complete weather data'
        )
      end
    end
  end

  describe 'GET #cache_status' do
    let(:status_data) do
      {
        current_cached: true,
        forecast_cached: false,
        zip_code: zip_code,
        timestamp: Time.current
      }
    end

    context 'with valid zip code' do
      before do
        allow(WeatherForecastService).to receive(:cache_status)
          .with(zip_code).and_return(status_data)
      end

      it 'returns cache status' do
        get :cache_status, params: { zip_code: zip_code }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'data' => hash_including(
            'current_cached' => true,
            'forecast_cached' => false,
            'zip_code' => zip_code
          )
        )
      end
    end
  end

  describe 'DELETE #clear_cache' do
    context 'with valid zip code' do
      before do
        allow(WeatherForecastService).to receive(:clear_cache)
          .with(zip_code).and_return(true)
      end

      it 'clears cache successfully' do
        delete :clear_cache, params: { zip_code: zip_code }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'data' => hash_including('zip_code' => zip_code)
        )
      end
    end

    context 'when service fails' do
      before do
        allow(WeatherForecastService).to receive(:clear_cache)
          .with(zip_code).and_return(false)
      end

      it 'returns error response' do
        delete :clear_cache, params: { zip_code: zip_code }

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to include(
          'success' => false,
          'error' => 'Failed to clear cache'
        )
      end
    end
  end
end
