require "sidekiq/web"
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :posts, only: [ :create ] do
        get "top_rated", on: :collection
        get "ip_authors", on: :collection
      end

      resources :ratings, only: [ :create ]
    end
  end
end
