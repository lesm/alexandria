Rails.application.routes.draw do
  scope :api do
    resources :books, except: :put
    resources :authors, except: :put
    resources :publishers, except: :put
    resources :users, except: :put

    resources :user_confirmations, only: :show, param: :confirmation_token
    resources :password_resets, only: [:show, :create, :update],
                                param: :reset_token

    resources :access_tokens, only: :create do
      delete '/', action: :destroy, on: :collection
    end

    get '/search/:text', to: 'search#index'
  end

  root to: 'book#index'
end
