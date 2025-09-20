# frozen_string_literal: true

# Rate limiting concern for API endpoints
module RateLimitable
  extend ActiveSupport::Concern

  RATE_LIMIT_WINDOW = 1.hour
  RATE_LIMIT_MAX_REQUESTS = 100

  included do
    before_action :check_rate_limit, if: -> { request.path.start_with?('/api') }
  end

  private

  def check_rate_limit
    client_ip = request.remote_ip
    key = "rate_limit:#{client_ip}"
    
    current_count = Rails.cache.read(key) || 0
    
    if current_count >= RATE_LIMIT_MAX_REQUESTS
      Rails.logger.warn("Rate limit exceeded for IP=#{client_ip}, count=#{current_count}")
      render_error('Rate limit exceeded. Please try again later.', 429)
      return
    end
    
    Rails.cache.write(key, current_count + 1, expires_in: RATE_LIMIT_WINDOW)
  end

  def render_error(message, status)
    render json: {
      success: false,
      error: message,
      timestamp: Time.current
    }, status: status
  end
end
