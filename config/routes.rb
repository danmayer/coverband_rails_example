Rails.application.routes.draw do
  resources :books
  resources :posts

  # Demo routes
  get "demo" => "demo#index", as: :demo
  get "demo/configuration" => "demo#configuration", as: :demo_configuration
  get "demo/benchmarks" => "demo#benchmarks", as: :demo_benchmarks
  get "demo/profiling" => "demo#profiling", as: :demo_profiling

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "demo#index"

  # NOTE: This is a demo, in a real app you would want to secure this route
  # For example, to protect the route
  # authenticate :user, lambda { |u| u.admin? } do
  #   mount Coverband::Reporters::Web.new, at: '/coverage'
  # end
  # This is how you mount coverband
  mount Coverband::Reporters::Web.new, at: "/coverage"
end
