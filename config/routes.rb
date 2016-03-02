Chessapp::Application.routes.draw do
  devise_for :players
  
  root 'static_pages#index'
  
  resources :games, only: [:new, :create, :show] do
    resources :pieces, only: [:show, :update]
  end
end
