# frozen_string_literal: true

# Health check controller for API monitoring
class Api::V1::HealthController < ApplicationController
  # GET /api/v1/health
  # Returns API health status and system information
  def index
    health_data = {
      status: 'healthy',
      timestamp: Time.current,
      version: '1.0.0',
      services: {
        database: database_status,
        redis: redis_status,
        external_api: external_api_status
      }
    }

    render json: health_data, status: :ok
  end

  private

  # Checks database connectivity
  # @return [Hash] Database status information
  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    { status: 'connected', message: 'Database connection successful' }
  rescue StandardError => e
    { status: 'error', message: e.message }
  end

  # Checks Redis connectivity
  # @return [Hash] Redis status information
  def redis_status
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
    redis.ping
    { status: 'connected', message: 'Redis connection successful' }
  rescue StandardError => e
    { status: 'error', message: e.message }
  end

  # Checks external API connectivity (OpenWeather)
  # @return [Hash] External API status information
  def external_api_status
    api_key = ENV.fetch('OPENWEATHER_API_KEY', '')
    if api_key.present?
      { status: 'configured', message: 'OpenWeather API key is configured' }
    else
      { status: 'not_configured', message: 'OpenWeather API key is missing' }
    end
  end
end
