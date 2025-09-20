# frozen_string_literal: true

# Simple metrics tracking for observability
module MetricsTracker
  extend ActiveSupport::Concern

  included do
    after_action :track_request_metrics, if: -> { request.path.start_with?('/api') }
  end

  private

  def track_request_metrics
    # Track basic metrics in Redis
    metrics_key = "metrics:#{Date.current.strftime('%Y-%m-%d')}"
    
    begin
      # Use Redis directly for list operations
      redis = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0'))
      
      # Increment request count
      redis.incr("#{metrics_key}:requests")
      
      # Track response time
      if @start_time
        response_time = ((Time.current - @start_time) * 1000).round(2)
        redis.lpush("#{metrics_key}:response_times", response_time)
        redis.expire("#{metrics_key}:response_times", 7.days)
      end
      
      # Track status codes
      status_code = response.status
      redis.incr("#{metrics_key}:status_#{status_code}")
      
      # Track endpoint usage
      endpoint = request.path.gsub(/\/\d+/, '/:id') # Normalize paths with IDs
      redis.incr("#{metrics_key}:endpoint_#{endpoint}")
    rescue => e
      Rails.logger.error("Metrics tracking error: #{e.message}")
    end
  end

  def start_request_timing
    @start_time = Time.current
  end
end
