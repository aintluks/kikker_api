Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :posts, only: [ :create ] do
        get "top_rated", on: :collection
      end

      resources :ratings, only: [ :create ]
    end
  end
end
