# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health API', type: :request do
  describe 'GET /api/v1/health' do
    context 'when all services are healthy' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_return(true)
        allow(Redis).to receive(:new).and_return(double(ping: 'PONG'))
        ENV['OPENWEATHER_API_KEY'] = 'test_key'
      end

      it 'returns healthy status' do
        get '/api/v1/health'

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
        get '/api/v1/health'

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'status' => 'healthy',
          'services' => hash_including(
            'database' => hash_including('status' => 'error')
          )
        )
      end
    end
  end

  describe 'GET /' do
    it 'redirects to health endpoint' do
      get '/'

      expect(response).to have_http_status(:ok)
    end
  end
end
