# 🌤️ Weather Forecast API

A professional-grade Ruby on Rails application that provides weather forecast data with intelligent caching, built following SOLID principles and industry best practices.

## ✨ Features

- **🌡️ Current Weather Data**: Real-time temperature, humidity, pressure, and conditions
- **📅 Extended Forecast**: 5-day weather predictions with detailed information
- **⚡ Smart Caching**: 30-minute Redis-based caching to reduce API calls and improve performance
- **🌍 Global Support**: US ZIP codes and Canadian postal codes
- **🔧 RESTful API**: Clean, documented endpoints with proper error handling
- **✅ Production Ready**: Comprehensive test coverage, SOLID principles, and scalable architecture
- **📱 Responsive UI**: Modern, mobile-friendly web interface
- **🔍 Cache Management**: Real-time cache status and manual cache clearing

## 🚀 Quick Start

### Prerequisites

- Ruby 3.0+
- Rails 7.2+
- PostgreSQL
- Redis
- OpenWeather API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd weather_forecast
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Configure environment variables**
   ```bash
   # Create .env file with:
   OPENWEATHER_API_KEY=your_api_key_here
   OPENWEATHER_BASE_URL=https://api.openweathermap.org/data/2.5
   REDIS_URL=redis://localhost:6379/0
   ```

5. **Start the application**
   ```bash
   rails server
   ```

6. **Visit the application**
   - Web Interface: http://localhost:3000
   - API Health: http://localhost:3000/api/v1/health

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Endpoints

#### Get Current Weather
```http
GET /api/v1/weather/current/:zip_code
```

**Example:**
```bash
curl http://localhost:3000/api/v1/weather/current/10001
```

**Response:**
```json
{
  "success": true,
  "message": "Current weather data retrieved successfully",
  "data": {
    "current": {
      "temperature": 20.5,
      "feels_like": 22.0,
      "humidity": 65,
      "pressure": 1013,
      "description": "clear sky",
      "icon": "01d"
    },
    "location": {
      "name": "New York",
      "country": "US",
      "zip_code": "10001"
    },
    "timestamp": "2024-01-15T10:30:00Z",
    "cached": false
  }
}
```

#### Get Extended Forecast
```http
GET /api/v1/weather/forecast/:zip_code
```

#### Get Complete Weather Data
```http
GET /api/v1/weather/complete/:zip_code
```

#### Check Cache Status
```http
GET /api/v1/weather/cache_status/:zip_code
```

#### Clear Cache
```http
DELETE /api/v1/weather/cache/:zip_code
```

#### Health Check
```http
GET /api/v1/health
```

## 🏗️ Architecture

### Service Layer (SOLID Principles)

#### WeatherService
- **Single Responsibility**: Handles external API communication
- **Open/Closed**: Extensible for different weather providers
- **Dependency Inversion**: Uses HTTParty for HTTP requests

#### CacheService
- **Strategy Pattern**: Pluggable cache backends
- **Single Responsibility**: Manages Redis caching operations
- **Interface Segregation**: Clean, focused methods

#### WeatherForecastService
- **Facade Pattern**: Simple interface for complex operations
- **Open/Closed**: Extensible for new weather data types
- **Dependency Inversion**: Depends on abstractions, not concretions

### Caching Strategy

- **Cache Duration**: 30 minutes for all weather data
- **Cache Keys**: `weather:{type}:{zip_code}`
- **Cache Indicators**: All responses include cache status
- **Cache Management**: Manual clearing and status checking

### Error Handling

- **Graceful Degradation**: API errors don't crash the application
- **User-Friendly Messages**: Clear error messages for different scenarios
- **Logging**: Comprehensive error logging for debugging
- **Status Codes**: Proper HTTP status codes for different error types

## 🧪 Testing

### Test Coverage
- **Unit Tests**: All services and models
- **Integration Tests**: API endpoints and controllers
- **Request Tests**: Full HTTP request/response cycles
- **Mocking**: External API calls are mocked for reliable testing

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Run specific test files
bundle exec rspec spec/services/weather_service_spec.rb
```

### Test Structure
```
spec/
├── controllers/          # Controller tests
├── services/            # Service layer tests
├── requests/            # API integration tests
└── support/            # Test configuration
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENWEATHER_API_KEY` | OpenWeather API key | Required |
| `OPENWEATHER_BASE_URL` | OpenWeather API base URL | `https://api.openweathermap.org/data/2.5` |
| `REDIS_URL` | Redis connection URL | `redis://localhost:6379/0` |
| `RAILS_ENV` | Rails environment | `development` |

### Supported ZIP Code Formats

- **US ZIP Codes**: `12345`, `12345-6789`
- **Canadian Postal Codes**: `K1A 0A6`

## 📊 Performance

### Caching Benefits
- **Reduced API Calls**: 30-minute cache reduces external API usage
- **Faster Response Times**: Cached data returns in milliseconds
- **Cost Efficiency**: Fewer API calls mean lower costs
- **Reliability**: Cached data available even if external API is down

### Scalability
- **Horizontal Scaling**: Stateless application design
- **Database Optimization**: Efficient queries and indexing
- **Redis Clustering**: Support for Redis cluster deployment
- **Load Balancing**: API-ready for load balancer deployment

## 🚀 Deployment

### Production Considerations

1. **Environment Variables**: Set all required environment variables
2. **Database**: Configure PostgreSQL for production
3. **Redis**: Set up Redis cluster for high availability
4. **Monitoring**: Implement health checks and monitoring
5. **Security**: Configure CORS and rate limiting
6. **SSL**: Use HTTPS in production

### Docker Support
```dockerfile
# Dockerfile included for containerized deployment
# Supports multi-stage builds for production optimization
```

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Code Standards
- **Ruby Style**: Follow Ruby style guide
- **Rails Conventions**: Follow Rails best practices
- **SOLID Principles**: Maintain clean architecture
- **Test Coverage**: Maintain high test coverage
- **Documentation**: Document all public methods

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **OpenWeather API** for weather data
- **Ruby on Rails** community for excellent framework
- **Redis** for fast caching solution
- **RSpec** for comprehensive testing framework

---

**Built with ❤️ using Ruby on Rails, Redis, and modern web technologies.**