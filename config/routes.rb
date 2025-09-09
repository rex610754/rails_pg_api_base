require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  if Rails.env.development?
    # Direct access in development
    mount Sidekiq::Web => '/sidekiq'
  else
    # HTTP Basic Auth in production
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
    end

    mount Sidekiq::Web => '/sidekiq'
  end

  # Checking app health
  get "/health", to: "health#index"

  # Defines the root path route ("/")
  # root "posts#index"
end
