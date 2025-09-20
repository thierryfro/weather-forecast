# frozen_string_literal: true

# Input validation concern for security
module InputValidator
  extend ActiveSupport::Concern

  included do
    before_action :sanitize_inputs, if: -> { request.path.start_with?('/api') }
  end

  private

  def sanitize_inputs
    # Sanitize zip_code parameter
    if params[:zip_code].present?
      sanitized_zip = params[:zip_code].strip.gsub(/[^A-Za-z0-9\s\-]/, '')
      
      if sanitized_zip != params[:zip_code]
        Rails.logger.warn("Input sanitization: zip_code=#{params[:zip_code]} -> #{sanitized_zip}")
        params[:zip_code] = sanitized_zip
      end
    end
  end

  def validate_zip_code_format(zip_code)
    return false if zip_code.blank?
    
    # US ZIP codes: 12345 or 12345-6789
    us_zip = zip_code.match?(/\A\d{5}(-\d{4})?\z/)
    
    # Canadian postal codes: A1A 1A1
    ca_zip = zip_code.match?(/\A[A-Z]\d[A-Z] \d[A-Z]\d\z/i)
    
    us_zip || ca_zip
  end
end
