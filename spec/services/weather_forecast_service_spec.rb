# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherForecastService, type: :service do
  let(:zip_code) { '10001' }
  let(:weather_data) do
    {
      current: { temperature: 20.5, description: 'clear sky' },
      location: { name: 'New York', country: 'US' },
      timestamp: Time.current
    }
  end
  let(:forecast_data) do
    {
      location: { name: 'New York', country: 'US' },
      forecast: [
        { datetime: Time.current, temperature: 20.5, description: 'clear sky' }
      ],
      timestamp: Time.current
    }
  end

  describe '.current_weather' do
    context 'with valid zip code' do
      context 'when data is in cache' do
        before do
          allow(CacheService).to receive(:get).with(zip_code, :current)
            .and_return(weather_data.merge(cached: true))
        end

        it 'returns cached data' do
          result = described_class.current_weather(zip_code)

          expect(result).to include(weather_data)
          expect(result[:cached]).to be true
        end
      end

      context 'when data is not in cache' do
        before do
          allow(CacheService).to receive(:get).with(zip_code, :current)
            .and_return(nil)
          allow(WeatherService).to receive(:current_weather).with(zip_code)
            .and_return(weather_data)
          allow(CacheService).to receive(:set).with(zip_code, weather_data, :current)
            .and_return(true)
        end

        it 'fetches from API and caches the result' do
          result = described_class.current_weather(zip_code)

          expect(result).to eq(weather_data)
          expect(WeatherService).to have_received(:current_weather).with(zip_code)
          expect(CacheService).to have_received(:set).with(zip_code, weather_data, :current)
        end
      end

      context 'when API returns error' do
        let(:error_data) { { error: true, message: 'API error', code: 500 } }

        before do
          allow(CacheService).to receive(:get).with(zip_code, :current)
            .and_return(nil)
          allow(WeatherService).to receive(:current_weather).with(zip_code)
            .and_return(error_data)
        end

        it 'returns error without caching' do
          result = described_class.current_weather(zip_code)

          expect(result).to eq(error_data)
        end
      end
    end

    context 'with invalid zip code' do
      it 'raises ArgumentError for blank zip code' do
        expect { described_class.current_weather('') }
          .to raise_error(ArgumentError, 'Zip code cannot be blank')
      end

      it 'raises ArgumentError for nil zip code' do
        expect { described_class.current_weather(nil) }
          .to raise_error(ArgumentError, 'Zip code cannot be blank')
      end

      it 'raises ArgumentError for invalid format' do
        expect { described_class.current_weather('invalid') }
          .to raise_error(ArgumentError, 'Invalid zip code format')
      end
    end
  end

  describe '.forecast' do
    context 'with valid zip code' do
      context 'when data is in cache' do
        before do
          allow(CacheService).to receive(:get).with(zip_code, :forecast)
            .and_return(forecast_data.merge(cached: true))
        end

        it 'returns cached data' do
          result = described_class.forecast(zip_code)

          expect(result).to include(forecast_data)
          expect(result[:cached]).to be true
        end
      end

      context 'when data is not in cache' do
        before do
          allow(CacheService).to receive(:get).with(zip_code, :forecast)
            .and_return(nil)
          allow(WeatherService).to receive(:forecast).with(zip_code)
            .and_return(forecast_data)
          allow(CacheService).to receive(:set).with(zip_code, forecast_data, :forecast)
            .and_return(true)
        end

        it 'fetches from API and caches the result' do
          result = described_class.forecast(zip_code)

          expect(result).to eq(forecast_data)
          expect(WeatherService).to have_received(:forecast).with(zip_code)
          expect(CacheService).to have_received(:set).with(zip_code, forecast_data, :forecast)
        end
      end
    end
  end

  describe '.complete_forecast' do
    context 'with valid zip code' do
      before do
        allow(described_class).to receive(:current_weather).with(zip_code)
          .and_return(weather_data)
        allow(described_class).to receive(:forecast).with(zip_code)
          .and_return(forecast_data)
      end

      it 'returns combined current and forecast data' do
        result = described_class.complete_forecast(zip_code)

        expect(result).to include(
          current: weather_data,
          forecast: forecast_data,
          location: weather_data[:location],
          timestamp: be_present
        )
      end
    end
  end

  describe '.clear_cache' do
    context 'with valid zip code' do
      before do
        allow(CacheService).to receive(:clear).with(zip_code).and_return(true)
      end

      it 'clears cache for the zip code' do
        result = described_class.clear_cache(zip_code)

        expect(result).to be true
        expect(CacheService).to have_received(:clear).with(zip_code)
      end
    end

    context 'with invalid zip code' do
      it 'raises ArgumentError' do
        expect { described_class.clear_cache('invalid') }
          .to raise_error(ArgumentError, 'Invalid zip code format')
      end
    end
  end

  describe '.cache_status' do
    context 'with valid zip code' do
      before do
        allow(CacheService).to receive(:exists?).with(zip_code, :current)
          .and_return(true)
        allow(CacheService).to receive(:exists?).with(zip_code, :forecast)
          .and_return(false)
      end

      it 'returns cache status for both current and forecast' do
        result = described_class.cache_status(zip_code)

        expect(result).to include(
          current_cached: true,
          forecast_cached: false,
          zip_code: zip_code,
          timestamp: be_present
        )
      end
    end
  end

  describe 'zip code validation' do
    it 'validates US zip codes' do
      expect(described_class.send(:valid_zip_code?, '12345')).to be true
      expect(described_class.send(:valid_zip_code?, '12345-6789')).to be true
    end

    it 'validates Canadian postal codes' do
      expect(described_class.send(:valid_zip_code?, 'K1A 0A6')).to be true
    end

    it 'rejects invalid formats' do
      expect(described_class.send(:valid_zip_code?, '1234')).to be false
      expect(described_class.send(:valid_zip_code?, '123456')).to be false
      expect(described_class.send(:valid_zip_code?, 'K1A0A6')).to be false
    end
  end
end
