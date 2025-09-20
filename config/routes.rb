Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Weather API routes
  namespace :api do
    namespace :v1 do
      # Weather forecast endpoints
      get 'weather/current/:zip_code', to: 'weather#current'
      get 'weather/forecast/:zip_code', to: 'weather#forecast'
      get 'weather/complete/:zip_code', to: 'weather#complete'
      get 'weather/cache_status/:zip_code', to: 'weather#cache_status'
      delete 'weather/cache/:zip_code', to: 'weather#clear_cache'
      
      # System monitoring endpoints
      get 'health', to: 'health#index'
      get 'metrics', to: 'metrics#index'
    end
  end

  # Web interface routes
  root 'home#index'
  post 'search', to: 'home#search'
  delete 'clear_cache', to: 'home#clear_cache'

  # API documentation route
  get 'api', to: 'api/v1/health#index'
end
