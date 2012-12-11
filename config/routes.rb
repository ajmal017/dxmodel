Nilesh::Application.routes.draw do
  root :to => "home#index" 

  resources :stock_dates
  resources :stocks
  resources :industries

  match 'reports/index', :to => "reports#index", :as => :reports

  resources :uploads
end
