Foolbits::Application.routes.draw do

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'signout', to: 'sessions#destroy'

  get 'user', to: 'sessions#get'

  get 'setup', to: "crypto#setup"
  
  root 'crypto#index'

end