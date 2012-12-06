Nilesh::Application.routes.draw do
  root :to => "home#index" 

  resources :stock_scores
  resources :stocks
  resources :industries

  match 'reports/long', :to => "reports#long", :as => :long_reports
  match 'reports/short', :to => "reports#short", :as => :short_reports

  resources :uploads
end
