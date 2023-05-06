Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  root 'home#index'

  get 'reports/update_task_checkboxes'
  get 'reports/update_member_checkboxes'
  get 'reports/render_custom_timeframe'
  get 'reports/update_projects_select'

  resources :reports, only: [:index, :new, :create]
  resources :clients
  resources :tasks
  resources :time_regs do
    patch :toggle_active

    collection do
      get 'export'
      post 'import'
    end
  end

  resources :projects do
    resources :memberships
    resources :assigned_tasks
    get 'export', to: 'projects#export', as: 'export_project_time_reg'
  end
end

