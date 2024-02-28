Rails.application.routes.draw do
  resources :books
  resources :posts

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "posts#index"

  # NOTE: This is a demo, in a real app you would want to secure this route
  # For example, to protect the route
  # authenticate :user, lambda { |u| u.admin? } do
  #   mount Coverband::Reporters::Web.new, at: '/coverage'
  # end
  if ENV["COVERBAND_PAGER"]
    # This is how you mount the experimental paged coverband for large projects
    mount Coverband::Reporters::WebPager.new, at: '/coverage'
  else
    # This is how you mount coverband
    mount Coverband::Reporters::Web.new, at: '/coverage'
  end
end
