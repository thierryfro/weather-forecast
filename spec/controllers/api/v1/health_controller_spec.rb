# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::HealthController, type: :controller do
  describe 'GET #index' do
    context 'when all services are healthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_return(true)
        allow(Redis).to receive(:new).and_return(double(ping: 'PONG'))
        ENV['OPENWEATHER_API_KEY'] = 'test_key'
      end

      it 'returns healthy status' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'status' => 'healthy',
          'version' => '1.0.0',
          'services' => hash_including(
            'database' => hash_including('status' => 'connected'),
            'redis' => hash_including('status' => 'connected'),
            'external_api' => hash_including('status' => 'configured')
          )
        )
      end
    end

    context 'when database is unhealthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute)
          .and_raise(StandardError.new('Connection failed'))
        allow(Redis).to receive(:new).and_return(double(ping: 'PONG'))
        ENV['OPENWEATHER_API_KEY'] = 'test_key'
      end

      it 'returns database error status' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'status' => 'healthy',
          'services' => hash_including(
            'database' => hash_including('status' => 'error')
          )
        )
      end
    end

    context 'when Redis is unhealthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_return(true)
        allow(Redis).to receive(:new).and_raise(StandardError.new('Connection failed'))
        ENV['OPENWEATHER_API_KEY'] = 'test_key'
      end

      it 'returns Redis error status' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'status' => 'healthy',
          'services' => hash_including(
            'redis' => hash_including('status' => 'error')
          )
        )
      end
    end

    context 'when API key is missing' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_return(true)
        allow(Redis).to receive(:new).and_return(double(ping: 'PONG'))
        ENV.delete('OPENWEATHER_API_KEY')
      end

      it 'returns external API not configured status' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'status' => 'healthy',
          'services' => hash_including(
            'external_api' => hash_including('status' => 'not_configured')
          )
        )
      end
    end
  end
end
