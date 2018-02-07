Rails.application.routes.draw do
  #resources :photos

  devise_for :users, controllers: {
    registrations: 'registrations', 
    passwords: 'passwords'
  }

  # recover key
  devise_scope :user do 
    get '/users/token(?:format)', to: 'users#token', as: 'token_user'
    post '/users/recover(?:format)', to: 'users#recover', as: 'recover_user'
    post '/users/recover_message(?:format)', to: 'users#recover_message', as: 'recover_message_user'
  end 
  
  # notein
  get '/terms', to: 'home#terms'
  get '/privacy', to: 'home#privacy'
      
  # tags
  get '/tags/:tag', to: 'tags#show'
  get '/tags/:tag/*tags', to: 'tags#show'
  get ':username/tags/:tag', to: 'tags#show'
  get ':username/tags/:tag/*tags', to: 'tags#show'
  
  # search
  get '/search/:term', to: 'search#show'
  get ':username/search/:term', to: 'search#show'
  
  match 'sorry', to: 'home#sorry', via: :get
  
  # users
  get ':username', to: 'users#show', as: :user
  get ':username/edit', to: 'users#edit'
    
  # memos
  get ':username/new', to: 'memos#new'
  get ':username/:id', to: 'memos#show'
  get ':username/:id/edit', to: 'memos#edit'
  post ':username/:id', to: 'memos#create'
  post ':username/:id/edit', to: 'memos#update'
  delete ':username/:id', to: 'memos#destroy'
  
  root to: 'home#index'
end
