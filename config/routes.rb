Rails.application.routes.draw do
  resources :hissekis, only: [:new, :create, :index]
  resources :users
  get "login", to: "user_sessions#new"
  post "login", to: "user_sessions#create"
  delete "logout", to: "user_sessions#destroy"
  post "learn", to: "hissekis#learn"
  root "users#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
