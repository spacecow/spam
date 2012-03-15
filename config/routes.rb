Spam::Application.routes.draw do
  get "filters/index"

  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  resources :sessions, :only => [:new,:create,:destroy]

  resources :filters, :only => :index do
    collection do
      get :forward
      put :update_multiple_forward
    end
  end
  get 'forward' => 'filters#forward'

  resources :locales, :only => :index
  resources :translations, :only => [:index,:create] do
    collection do
      put :update_multiple
    end
  end

  get 'welcome' => 'filters#forward'
  root :to => 'filters#forward'
end
