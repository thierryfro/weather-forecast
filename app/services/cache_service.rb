# frozen_string_literal: true

# Service class for managing weather data caching
# Implements Strategy pattern for different cache backends
class CacheService
  CACHE_EXPIRY = 30.minutes

  class << self
    # Retrieves cached weather data for a zip code
    # @param zip_code [String] The zip code to retrieve cache for
    # @param cache_type [Symbol] Type of cache (:current or :forecast)
    # @return [Hash, nil] Cached data or nil if not found/expired
    def get(zip_code, cache_type = :current)
      cache_key = build_cache_key(zip_code, cache_type)
      cached_data = redis.get(cache_key)
      
      return nil unless cached_data
      
      JSON.parse(cached_data).merge('cached' => true)
    rescue JSON::ParserError, Redis::BaseError => e
      Rails.logger.error "Cache retrieval error: #{e.message}"
      nil
    end

    # Stores weather data in cache
    # @param zip_code [String] The zip code
    # @param data [Hash] Weather data to cache
    # @param cache_type [Symbol] Type of cache (:current or :forecast)
    # @return [Boolean] Success status
    def set(zip_code, data, cache_type = :current)
      cache_key = build_cache_key(zip_code, cache_type)
      cache_data = data.merge(cached: false, cached_at: Time.current)
      
      redis.setex(cache_key, CACHE_EXPIRY.to_i, cache_data.to_json)
      true
    rescue Redis::BaseError => e
      Rails.logger.error "Cache storage error: #{e.message}"
      false
    end

    # Clears cache for a specific zip code
    # @param zip_code [String] The zip code to clear cache for
    # @return [Boolean] Success status
    def clear(zip_code)
      current_key = build_cache_key(zip_code, :current)
      forecast_key = build_cache_key(zip_code, :forecast)
      
      redis.del(current_key, forecast_key)
      true
    rescue Redis::BaseError => e
      Rails.logger.error "Cache clear error: #{e.message}"
      false
    end

    # Checks if data exists in cache
    # @param zip_code [String] The zip code to check
    # @param cache_type [Symbol] Type of cache (:current or :forecast)
    # @return [Boolean] Whether data exists in cache
    def exists?(zip_code, cache_type = :current)
      cache_key = build_cache_key(zip_code, cache_type)
      redis.exists?(cache_key)
    rescue Redis::BaseError => e
      Rails.logger.error "Cache existence check error: #{e.message}"
      false
    end

    private

    # Builds cache key for a zip code and cache type
    # @param zip_code [String] The zip code
    # @param cache_type [Symbol] Type of cache
    # @return [String] Cache key
    def build_cache_key(zip_code, cache_type)
      "weather:#{cache_type}:#{zip_code}"
    end

    # Returns Redis connection
    # @return [Redis] Redis connection instance
    def redis
      @redis ||= Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
    end
  end
end
