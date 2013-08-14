Foolbits::Application.routes.draw do

  get '/auth/:provider/callback', to: 'sessions#create'

  get 'signout', to: 'sessions#destroy'

  root 'crypto#index'

end