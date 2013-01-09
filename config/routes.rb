Dxmodel::Application.routes.draw do
  root :to => "home#index" 

  resources :stock_dates
  resources :stocks
  resources :industries
  resources :positions do
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

  match 'reports/index', :to => "reports#index", :as => :reports

  resources :uploads
end
