Rails.application.routes.draw do
  resources :forecast, only: :index
  root 'react#index'
end
