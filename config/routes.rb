Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'home/index'
  # Defines the root path route ("/")
  root 'home#index'

  resources :clients do
    resources :projects do
      resources :memberships
      resources :assigned_tasks
    end
  end
  resources :tasks
end
