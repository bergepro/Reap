Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations/registrations' }

  get 'home/index'
  root 'home#index'

  #resources :reports, only: [:index, :new, :create] do
  #  collection do
  #    get 'export_test'
  #  end
  #end
  #get 'reports/update_groupes_select'
  #get '/reports/index'
  #get 'reports/update_task_checkboxes'
  #get 'reports/update_member_checkboxes'
  #get 'reports/render_custom_timeframe'
  #get 'reports/update_projects_select'

  resources :project_reports do
    patch :update_group
    collection do
      get 'update_task_checkboxes'
      get 'update_member_checkboxes'
      get 'render_custom_timeframe'
      get 'update_projects_select'
      get 'export'
    end
  end

  resources :user_reports do
    collection do
      get 'update_projects_checkboxes'
      get 'update_tasks_checkboxes'
    end
  end

  resources :clients

  resources :tasks

  match 'projects/import' => 'projects#import', :via => :post
  resources :time_regs do
    patch :toggle_active
    collection do
      get 'export'
      post 'import'
      get 'update_tasks_select'
      get 'update_minutes_view'
      get 'new_modal', to: 'time_regs#new', as: :new_modal
    end
  end
  
  resources :projects do
    resources :memberships
    resources :assigned_tasks
    get 'export', to: 'projects#export', as: 'export_project_time_reg'
  end
end

