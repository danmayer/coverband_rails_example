Rails.application.routes.draw do
  resources :books
  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "posts#index"

  # This is how you mount coverband
  # NOTE: This is a demo, in a real app you would want to secure this route
  mount Coverband::Reporters::Web.new, at: '/coverage'

  # For example, to protect the route
  # authenticate :user, lambda { |u| u.admin? } do
  #   mount Coverband::Reporters::Web.new, at: '/coverage'
  # end
end
