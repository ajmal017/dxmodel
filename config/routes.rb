Dxmodel::Application.routes.draw do
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
  match '/reports/pl', controller: 'reports', action: 'pl', as: :pl_reports

end
