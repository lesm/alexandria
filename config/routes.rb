Rails.application.routes.draw do
  scope :api do
    get '/books', to: "books#index"
  end
end
