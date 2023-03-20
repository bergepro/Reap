Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'home/index'
  # Defines the root path route ("/")
  root 'home#index'

  get 'projects/index'
  
  resources :projects do
    resources :members
  end

  resources :projects do
    get 'add_member', to: 'members#new'
  end

  delete 'members/:id', to: 'members#destroy'
end
