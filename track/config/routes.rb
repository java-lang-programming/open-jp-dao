Rails.application.routes.draw do
  # resource :session
  # resources :passwords, param: :token

  # TODO root
  get "top" => "top#index"

  namespace :apis do
    post "solana/signin"
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

    get "downloads/:filename", to: "downloads#show", as: :download, constraints: { filename: /.+/ }

    get "sessions/nonce"
    post "sessions/verify"
    post "sessions/signin"
    post "sessions/signout"
    get "sessions/user"
  end

  resources :dollar_yen_transactions do
    member do
      get "delete_confirmation"
      put "edit_confirmation"
    end
    collection do
      # 為替差益
      get "foreign_exchange_gain"
      get "csv_upload"
      post "csv_import"
      post "create_confirmation"
      # module を指定することで DollarYenTransactions::CsvCoordinationsController を呼び出す
      scope module: :dollar_yen_transactions, as: :dollar_yen_transactions do
        resources :csv_coordinations, only: [ :index, :show, :destroy ] do
          # :id の配下に new と create を定義
          member do
            get :new
            post :create
          end
        end
      end
    end
  end

  resources :transaction_types

  resources :import_files, only: [ :index ] do
    member do
      get "result"
    end
  end

  resources :settings, only: [ :index ]
  resources :help, only: [ :index ]

  # v2
  resources :ledgers do
    collection do
      get "csv_upload_new"
      post "csv_upload"
      # POSTリクエストで複数のIDを受け取り、削除するアクション
      # POST /ledgers/destroy_multiple
      post "destroy_multiple"
    end
  end

  resources :tax_returns, only: [ :index ]

  post "sessions/logout"
  get "sessions/signout"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
