Rails.application.routes.draw do
  root                      to: 'sessions#new'
  post   '/sign_in',        to: 'sessions#create'
  delete '/sign_out',       to: 'sessions#destroy'
  get    '/oauth/callback', to: 'oauth#callback'
  scope :users do
    resources :photos, only: [ :index, :new, :create ] do
      post 'tweet', on: :member
    end
  end
end
