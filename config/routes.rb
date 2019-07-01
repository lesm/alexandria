Rails.application.routes.draw do
  scope :api do
    get '/books', to: "books#index"
    get '/books/:id', to: "books#show", as: :book
    post '/books', to: "books#create"
    patch '/books/:id', to: "books#update"
    delete '/books/:id', to: "books#destroy"
  end
end
