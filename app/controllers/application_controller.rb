class ApplicationController < ActionController::Base
  include RateLimitable
  include InputValidator
  include MetricsTracker
  
  before_action :start_request_timing, if: -> { request.path.start_with?('/api') }
end
