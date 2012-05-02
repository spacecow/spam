Spam::Application.routes.draw do
  get "filters/index"

  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  resources :sessions, :only => [:new,:create,:destroy]

  resources :filters, :only => :create do
    collection do
      get :forward
      put :update_multiple_forward
      get :antispam
      put :update_multiple_antispam
    end
  end
  get 'forwarding' => 'filters#forward'
  get 'filtering' => 'filters#antispam'

  resources :locales, :only => :index
  resources :translations, :only => [:index,:create] do
    collection do
      put :update_multiple
    end
  end

  get 'welcome' => 'filters#forward'
  root :to => 'filters#forward'
end
