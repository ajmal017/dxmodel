Dxmodel::Application.routes.draw do
  get "sessions/new"

  get "users/new"

  root :to => "home#index" 

  resources :fx_rates
  resources :stock_dates
  resources :stocks
  resources :industries
  resources :trades do
    collection do
      get 'signaled'
      get 'entered'
      get 'exited'
    end
    member do
      get 'enter'
      put 'enter'
      get 'exit'
      put 'exit'
    end
  end

  match '/reports/exposure', controller: 'reports', action: 'exposure', as: :exposure_reports
  match '/reports/aum', controller: 'reports', action: 'aum', as: :aum_reports
  match '/reports/pnl', controller: 'reports', action: 'pnl', as: :pnl_reports
  match '/reports/day', controller: 'reports', action: 'day', as: :day_reports
  match '/reports/inout', controller: 'reports', action: 'inout', as: :inout_reports


  # User registrations and sessions
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"
  root :to => "users#new"
  resources :users
  resources :sessions

end
