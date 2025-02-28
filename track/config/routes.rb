Rails.application.routes.draw do
  # resource :session
  # resources :passwords, param: :token

  # TODO root
  get "top" => "top#index"

  namespace :apis do
    get "import_files/index"
    get "notifications/index"
    resources :dollar_yens do
      collection do
        post "csv_import"
      end
    end
    resources :transaction_types
    namespace :dollaryen do
      resources :transactions
      resources :foreigne_exchange_gain
      post "transactions/csv_import"
      resources :downloads, only: [ :show ]
    end

    get "sessions/nonce"
    post "sessions/verify"
    post "sessions/signin"
    post "sessions/signout"
    get "sessions/user"
  end

  resources :dollar_yen_transactions do
    collection do
      get "csv_upload"
      post "csv_import"
      post "create_confirmation"
    end
  end

  resources :import_files, only: [ :index ]


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
