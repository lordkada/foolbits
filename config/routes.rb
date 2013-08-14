Foolbits::Application.routes.draw do

  get '/auth/:provider/callback', to: 'sessions#create'

  root 'crypto#index'

end