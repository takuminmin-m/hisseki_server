Rails.application.routes.draw do
  root "static_pages#home"
  resources :hissekis, only: [:new, :create, :index]
  resources :users
  get "login", to: "user_sessions#new"
  post "login", to: "user_sessions#create"
  delete "logout", to: "user_sessions#destroy"
  get "learn", to: "hissekis#learn"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
