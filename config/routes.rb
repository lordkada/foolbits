Foolbits::Application.routes.draw do

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'signout', to: 'sessions#destroy'

  get 'user', to: 'sessions#get'

  get 'setup', to: "crypto#setup"
  get 'vault', to: "crypto#vault"
  post 'keypair', to: "crypto#keypair"
  put 'vault', to: "crypto#set_vault"
  
  get 'faq', to: "faq#index"
  
  root 'crypto#index'

end