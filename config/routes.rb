Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  root 'home#index'



  resources :reports, only: [:index, :new, :create]  
  get 'reports/update_groupes_select'
  get '/reports/index'
  get 'reports/update_task_checkboxes'
  get 'reports/update_member_checkboxes'
  get 'reports/render_custom_timeframe'
  get 'reports/update_projects_select'


  resources :clients

  resources :tasks

  resources :time_regs do
    patch :toggle_active
    collection do
      get 'export'
      post 'import'
      get 'update_tasks_select'
      get 'update_minutes_view'
    end

  end
  

  resources :projects do
    resources :memberships
    resources :assigned_tasks
    get 'export', to: 'projects#export', as: 'export_project_time_reg'
  end
end

