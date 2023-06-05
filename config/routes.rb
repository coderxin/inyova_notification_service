# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      post :sessions, to: 'sessions#create'
      delete :sessions, to: 'sessions#destroy'

      resources :notifications, only: [:index, :show] do
        scope module: 'notifications' do
          resource :reads, only: :update
        end
      end

      namespace :admin do
        resources :notifications, only: [:index, :show, :create] do
          scope module: 'notifications' do
            resources :assignments, only: [:index, :create]
          end
        end
      end
    end
  end
end


