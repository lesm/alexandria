Rails.application.routes.draw do
  scope :api do
    resources :books, except: :put
    resources :authors, except: :put
    resources :publishers, except: :put
    resources :users, except: :put

    resources :user_confirmations, only: :show, param: :confirmation_token

    get '/search/:text', to: 'search#index'
  end

  root to: 'book#index'
end
