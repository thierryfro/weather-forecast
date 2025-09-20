# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CacheService, type: :service do
  let(:zip_code) { '10001' }
  let(:weather_data) do
    {
      current: { temperature: 20.5, description: 'clear sky' },
      location: { name: 'New York', country: 'US' },
      timestamp: Time.current
    }
  end
  let(:redis) { instance_double(Redis) }

  before do
    allow(Redis).to receive(:new).and_return(redis)
    allow(CacheService).to receive(:redis).and_return(redis)
  end

  describe '.get' do
    context 'when data exists in cache' do
      before do
        allow(redis).to receive(:get).with("weather:current:#{zip_code}")
          .and_return(weather_data.to_json)
      end

      it 'returns cached data with cached flag' do
        result = described_class.get(zip_code, :current)

        expect(result).to include('cached' => true)
        expect(result['current']).to include('temperature' => 20.5, 'description' => 'clear sky')
        expect(result['location']).to include('name' => 'New York', 'country' => 'US')
        expect(result['timestamp']).to be_present
      end
    end

    context 'when data does not exist in cache' do
      before do
        allow(redis).to receive(:get).with("weather:current:#{zip_code}")
          .and_return(nil)
      end

      it 'returns nil' do
        result = described_class.get(zip_code, :current)
        expect(result).to be_nil
      end
    end

    context 'when Redis error occurs' do
      before do
        allow(redis).to receive(:get).and_raise(Redis::BaseError.new('Connection failed'))
      end

      it 'returns nil and logs error' do
        expect(Rails.logger).to receive(:error).with(/Cache retrieval error/)
        result = described_class.get(zip_code, :current)
        expect(result).to be_nil
      end
    end

    context 'when JSON parsing fails' do
      before do
        allow(redis).to receive(:get).with("weather:current:#{zip_code}")
          .and_return('invalid json')
      end

      it 'returns nil and logs error' do
        expect(Rails.logger).to receive(:error).with(/Cache retrieval error/)
        result = described_class.get(zip_code, :current)
        expect(result).to be_nil
      end
    end
  end

  describe '.set' do
    context 'when cache storage is successful' do
      before do
        allow(redis).to receive(:setex).and_return('OK')
      end

      it 'stores data in cache and returns true' do
        result = described_class.set(zip_code, weather_data, :current)

        expect(result).to be true
        expect(redis).to have_received(:setex)
          .with("weather:current:#{zip_code}", 1800, anything)
      end
    end

    context 'when Redis error occurs' do
      before do
        allow(redis).to receive(:setex).and_raise(Redis::BaseError.new('Connection failed'))
      end

      it 'returns false and logs error' do
        expect(Rails.logger).to receive(:error).with(/Cache storage error/)
        result = described_class.set(zip_code, weather_data, :current)
        expect(result).to be false
      end
    end
  end

  describe '.clear' do
    context 'when cache clearing is successful' do
      before do
        allow(redis).to receive(:del).and_return(2)
      end

      it 'clears cache for both current and forecast' do
        result = described_class.clear(zip_code)

        expect(result).to be true
        expect(redis).to have_received(:del)
          .with("weather:current:#{zip_code}", "weather:forecast:#{zip_code}")
      end
    end

    context 'when Redis error occurs' do
      before do
        allow(redis).to receive(:del).and_raise(Redis::BaseError.new('Connection failed'))
      end

      it 'returns false and logs error' do
        expect(Rails.logger).to receive(:error).with(/Cache clear error/)
        result = described_class.clear(zip_code)
        expect(result).to be false
      end
    end
  end

  describe '.exists?' do
    context 'when data exists in cache' do
      before do
        allow(redis).to receive(:exists?).with("weather:current:#{zip_code}")
          .and_return(true)
      end

      it 'returns true' do
        result = described_class.exists?(zip_code, :current)
        expect(result).to be true
      end
    end

    context 'when data does not exist in cache' do
      before do
        allow(redis).to receive(:exists?).with("weather:current:#{zip_code}")
          .and_return(false)
      end

      it 'returns false' do
        result = described_class.exists?(zip_code, :current)
        expect(result).to be false
      end
    end

    context 'when Redis error occurs' do
      before do
        allow(redis).to receive(:exists?).and_raise(Redis::BaseError.new('Connection failed'))
      end

      it 'returns false and logs error' do
        expect(Rails.logger).to receive(:error).with(/Cache existence check error/)
        result = described_class.exists?(zip_code, :current)
        expect(result).to be false
      end
    end
  end
end
