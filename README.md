# Weather Forecast API

A professional weather forecast API built with Ruby on Rails, featuring advanced observability, security, and monitoring capabilities.

## 🚀 Features

### Core Functionality
- **Current Weather** - Real-time weather data for any location
- **Extended Forecast** - 5-day weather forecast with detailed information
- **Complete Forecast** - Combined current and extended forecast data
- **Cache Management** - Redis-based caching with intelligent cache invalidation

### Professional Features
- **Observability** - Structured logging, metrics tracking, and performance monitoring
- **Security** - Rate limiting, input validation, and security event logging
- **Monitoring** - Real-time metrics endpoint with response time analytics
- **Scalability** - Redis-based architecture for high-performance caching

## 🏗️ Architecture

### Design Patterns
- **Facade Pattern** - `WeatherForecastService` provides a simple interface to complex weather operations
- **Single Responsibility** - Each service handles one specific concern
- **Concerns** - Reusable modules for cross-cutting concerns (rate limiting, metrics, validation)

### Technology Stack
- **Ruby on Rails 7.2.2.2** - Web framework
- **PostgreSQL** - Primary database
- **Redis** - Caching and metrics storage
- **Docker** - Containerized development environment
- **OpenWeather API** - External weather data source

## 📊 Observability & Monitoring

### Structured Logging
```ruby
Rails.logger.info("WeatherService: Successfully fetched weather for zip_code=#{zip_code}, response_time=#{response_time}ms")
```

### Real-time Metrics
- Request counting and response time tracking
- Status code monitoring
- Endpoint usage analytics
- Performance metrics (p95, average, min, max)

### Security Features
- Rate limiting (100 requests/hour per IP)
- Input validation and sanitization
- Security event logging
- Attack prevention

## 🛠️ Development Setup

### Prerequisites
- Docker and Docker Compose
- Git

### Quick Start
```bash
# Clone the repository
git clone https://github.com/thierryfro/weather_forecast.git
cd weather_forecast

# Start the application
docker compose up -d

# The application will be available at:
# - Web Interface: http://localhost:3000
# - API: http://localhost:3000/api/v1/
```

### Environment Configuration
Create a `.env` file with your OpenWeather API key:
```env
OPENWEATHER_API_KEY=your_api_key_here
```

## 📡 API Endpoints

### Weather Endpoints
- `GET /api/v1/weather/current/:zip_code` - Current weather
- `GET /api/v1/weather/forecast/:zip_code` - Extended forecast
- `GET /api/v1/weather/complete/:zip_code` - Complete forecast
- `GET /api/v1/weather/cache_status/:zip_code` - Cache status
- `DELETE /api/v1/weather/cache/:zip_code` - Clear cache

### System Endpoints
- `GET /api/v1/health` - Health check
- `GET /api/v1/metrics` - System metrics

### Web Interface
- `GET /` - Weather forecast web interface
- `POST /search` - Search weather by zip code
- `DELETE /clear_cache` - Clear application cache

## 📈 Metrics Example

```json
{
  "success": true,
  "data": {
    "requests": 7,
    "response_times": {
      "count": 1,
      "average": 1.79,
      "min": 1.79,
      "max": 1.79,
      "p95": 1.79
    },
    "status_codes": {
      "200": 1
    },
    "endpoints": {
      "/api/v1/health": 1
    }
  }
}
```

## 🔧 Production Features

### Observability
- Structured logging with context
- Real-time performance metrics
- Error tracking and monitoring
- Business metrics tracking

### Security
- Rate limiting with Redis
- Input validation and sanitization
- Security event logging
- Attack prevention mechanisms

### Scalability
- Redis-based caching
- Efficient data storage
- Real-time monitoring
- Horizontal scaling support

## 🧪 Testing

```bash
# Run tests
docker compose exec web bundle exec rspec

# Run with coverage
docker compose exec web bundle exec rspec --format documentation
```

## 📝 Code Quality

- **RuboCop** - Code style enforcement
- **RSpec** - Comprehensive test suite
- **CI/CD** - GitHub Actions workflow
- **Docker** - Consistent development environment

## 🚀 Deployment

The application is production-ready with:
- Docker containerization
- Environment-based configuration
- Redis for caching and metrics
- PostgreSQL for data persistence
- Comprehensive monitoring

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Thierry Froes** - [@thierryfro](https://github.com/thierryfro)

---

**Professional Rails API with Enterprise-grade Observability and Security** 🚀