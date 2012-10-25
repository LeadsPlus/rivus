Rivus::Application.routes.draw do
  devise_for :users

  root to: 'home#index'

  authenticate :user do
    get '/dashboard', to: 'dashboard#index', as: :dashboard

    resources :events
    resources :sources do
      get :authorize, on: :member
    end

    get '/auth/cb/:type', to: 'authorizations#cb', as: 'auth_callback'
  end
end
