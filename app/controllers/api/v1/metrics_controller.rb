# frozen_string_literal: true

# Metrics controller for system observability
class Api::V1::MetricsController < ApplicationController
  # GET /api/v1/metrics
  # Returns system metrics for monitoring
  def index
    today = Date.current.strftime('%Y-%m-%d')
    metrics_key = "metrics:#{today}"
    
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0'))
    metrics = {
      requests: redis.get("#{metrics_key}:requests").to_i,
      response_times: get_response_time_stats(metrics_key),
      status_codes: get_status_code_stats(metrics_key),
      endpoints: get_endpoint_stats(metrics_key),
      timestamp: Time.current
    }
    
    render_success(metrics, 'Metrics retrieved successfully')
  end

  private

  def get_response_time_stats(metrics_key)
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0'))
    times = redis.lrange("#{metrics_key}:response_times", 0, -1).map(&:to_f)
    return {} if times.empty?
    
    {
      count: times.length,
      average: (times.sum / times.length).round(2),
      min: times.min.round(2),
      max: times.max.round(2),
      p95: calculate_percentile(times, 95).round(2)
    }
  rescue => e
    Rails.logger.error("Error calculating response time stats: #{e.message}")
    {}
  end

  def get_status_code_stats(metrics_key)
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0'))
    status_codes = {}
    (200..599).each do |code|
      count = redis.get("#{metrics_key}:status_#{code}").to_i
      status_codes[code] = count if count > 0
    end
    status_codes
  rescue => e
    Rails.logger.error("Error getting status code stats: #{e.message}")
    {}
  end

  def get_endpoint_stats(metrics_key)
    redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0'))
    endpoints = {}
    %w[/api/v1/weather/current/:id /api/v1/weather/forecast/:id /api/v1/weather/complete/:id /api/v1/health /api/v1/metrics].each do |endpoint|
      count = redis.get("#{metrics_key}:endpoint_#{endpoint}").to_i
      endpoints[endpoint] = count if count > 0
    end
    endpoints
  rescue => e
    Rails.logger.error("Error getting endpoint stats: #{e.message}")
    {}
  end

  def calculate_percentile(values, percentile)
    sorted = values.sort
    index = (percentile / 100.0) * (sorted.length - 1)
    lower = sorted[index.floor]
    upper = sorted[index.ceil]
    lower + (upper - lower) * (index - index.floor)
  end

  def render_success(data, message)
    render json: {
      success: true,
      message: message,
      data: data,
      timestamp: Time.current
    }, status: :ok
  end
end
