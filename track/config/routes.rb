Rails.application.routes.draw do
  namespace :apis do
    namespace :dollaryen do
      resources :transactions
      resources :foreigne_exchange_gain
      post "transactions/csv_upload"
    end

    get "sessions/nonce"
    post "sessions/verify"
    post "sessions/signout"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
