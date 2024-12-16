Rails.application.routes.draw do
  # resource :session
  # resources :passwords, param: :token
  namespace :apis do
    resources :dollar_yens do
      collection do
        post "csv_import"
      end
    end
    namespace :dollaryen do
      # post "csv_import"
      resources :transactions
      resources :foreigne_exchange_gain
      post "transactions/csv_import"
    end

    get "sessions/nonce"
    post "sessions/verify"
    post "sessions/signin"
    post "sessions/signout"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
