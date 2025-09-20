# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:zip_code) { '10001' }
  let(:api_key) { 'test_api_key' }
  let(:base_url) { 'https://api.openweathermap.org/data/2.5' }

  before do
    ENV['OPENWEATHER_API_KEY'] = api_key
    ENV['OPENWEATHER_BASE_URL'] = base_url
  end

  describe '.current_weather' do
    let(:successful_response) do
      {
        'main' => {
          'temp' => 20.5,
          'feels_like' => 22.0,
          'humidity' => 65,
          'pressure' => 1013
        },
        'weather' => [
          {
            'description' => 'clear sky',
            'icon' => '01d'
          }
        ],
        'name' => 'New York',
        'sys' => { 'country' => 'US' },
        'zip_code' => zip_code
      }
    end

    context 'when API call is successful' do
      before do
        stub_request(:get, "#{base_url}/weather")
          .with(query: { zip: zip_code, units: 'metric', appid: 'test_key' })
          .to_return(
            status: 200,
            body: successful_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed weather data' do
        result = described_class.current_weather(zip_code)

        expect(result).to include(
          current: hash_including(
            temperature: 20.5,
            feels_like: 22.0,
            humidity: 65,
            pressure: 1013,
            description: 'clear sky',
            icon: '01d'
          ),
          location: hash_including(
            name: 'New York',
            country: 'US',
            zip_code: zip_code
          )
        )
        expect(result[:timestamp]).to be_present
      end
    end

    context 'when API call fails' do
      before do
        stub_request(:get, "#{base_url}/weather")
          .with(query: { zip: zip_code, units: 'metric', appid: 'test_key' })
          .to_return(
            status: 404,
            body: { 'message' => 'city not found' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns error information' do
        result = described_class.current_weather(zip_code)

        expect(result).to include(
          error: true,
          message: 'city not found',
          code: 404
        )
        expect(result[:timestamp]).to be_present
      end
    end

    context 'when network error occurs' do
      before do
        stub_request(:get, "#{base_url}/weather")
          .with(query: { zip: zip_code, units: 'metric', appid: 'test_key' })
          .to_raise(StandardError.new('Network error'))
      end

      it 'returns error information' do
        result = described_class.current_weather(zip_code)

        expect(result).to include(
          error: true,
          message: 'Network error',
          code: 500
        )
        expect(result[:timestamp]).to be_present
      end
    end
  end

  describe '.forecast' do
    let(:successful_response) do
      {
        'city' => {
          'name' => 'New York',
          'country' => 'US'
        },
        'list' => [
          {
            'dt' => Time.current.to_i,
            'main' => {
              'temp' => 20.5,
              'feels_like' => 22.0,
              'humidity' => 65,
              'pressure' => 1013
            },
            'weather' => [
              {
                'description' => 'clear sky',
                'icon' => '01d'
              }
            ]
          }
        ],
        'zip_code' => zip_code
      }
    end

    context 'when API call is successful' do
      before do
        stub_request(:get, "#{base_url}/forecast")
          .with(query: { zip: zip_code, units: 'metric', appid: 'test_key' })
          .to_return(
            status: 200,
            body: successful_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed forecast data' do
        result = described_class.forecast(zip_code)

        expect(result).to include(
          location: hash_including(
            name: 'New York',
            country: 'US',
            zip_code: zip_code
          ),
          forecast: array_including(
            hash_including(
              temperature: 20.5,
              feels_like: 22.0,
              humidity: 65,
              pressure: 1013,
              description: 'clear sky',
              icon: '01d'
            )
          )
        )
        expect(result[:timestamp]).to be_present
      end
    end

    context 'when API call fails' do
      before do
        stub_request(:get, "#{base_url}/forecast")
          .with(query: { zip: zip_code, units: 'metric', appid: 'test_key' })
          .to_return(
            status: 401,
            body: { 'message' => 'Invalid API key' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns error information' do
        result = described_class.forecast(zip_code)

        expect(result).to include(
          error: true,
          message: 'Invalid API key',
          code: 401
        )
        expect(result[:timestamp]).to be_present
      end
    end
  end
end
