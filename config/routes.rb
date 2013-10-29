Dxmodel::Application.routes.draw do
  get "sessions/new"

  get "users/new"

  root :to => "home#index" 

  resources :fx_rates
  resources :stock_dates
  resources :index_dates
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
      patch 'enter'
      get 'exit'
      patch 'exit'
    end
  end

  match '/reports/exposure', controller: 'reports', action: 'exposure', as: :exposure_reports, via: [:get]
  match '/reports/aum', controller: 'reports', action: 'aum', as: :aum_reports, via: [:get]
  match '/reports/pnl', controller: 'reports', action: 'pnl', as: :pnl_reports, via: [:get]
  match '/reports/day', controller: 'reports', action: 'day', as: :day_reports, via: [:get]
  match '/reports/inout', controller: 'reports', action: 'inout', as: :inout_reports, via: [:get]
  match '/reports/stock_dates', controller: 'reports', action: 'stock_dates', as: :stock_date_reports, via: [:get]


  # User registrations and sessions
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"
  resources :users
  resources :sessions
end
