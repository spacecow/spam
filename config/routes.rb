Spam::Application.routes.draw do
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  resources :sessions, :only => [:new,:create,:destroy]

  resources :forwards, :only => :index do
    collection do
      put :update_multiple
    end
  end

  resources :filters, :only => [:index,:new]

  resources :locales, :only => :index
  resources :translations, :only => [:index,:create] do
    collection do
      put :update_multiple
    end
  end


  root :to => 'sessions#new'
end
