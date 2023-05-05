Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'home/index'
  # Defines the root path route ("/")
  root 'home#index'

  get 'reports/update_task_checkboxes'
  get 'reports/update_member_checkboxes'
  get 'reports/render_custom_timeframe'
  get 'reports/update_projects_select'

  resources :reports, only: [:index, :new, :create] 
  
  resources :clients 
  resources :tasks

  resources :projects do
    resources :memberships
    resources :assigned_tasks

    resources :time_regs do
      patch :toggle_active
      
      collection do
        get 'export'
        post 'import'
      end
    end
  end

end
