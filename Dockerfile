# Use Ruby 3.1 slim image
FROM ruby:3.1-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile only
COPY Gemfile ./

# Install gems
RUN bundle install --without development test

# Copy application code
COPY . .

# Skip asset precompilation for now
# RUN bundle exec rails assets:precompile

# Create non-root user
RUN groupadd -r app && useradd -r -g app app
RUN chown -R app:app /app
USER app

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/v1/health || exit 1

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]