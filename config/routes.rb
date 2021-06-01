Rails.application.routes.draw do
  resources :users
  resources :hissekis, only: [:new, :create, :index]
  root "users#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
