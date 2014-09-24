Foolbits::Application.routes.draw do

    constraints(:host => /^foolbits.com/) do
        get '/(*path)', to: redirect { |params, request|
            p request.url
            URI.parse(request.url).tap { |x| x.host = "www.#{x.host}" }.to_s
        }
    end

    get '/auth/:provider/callback', to: 'sessions#create'
    get 'signout', to: 'sessions#destroy'

    get 'user', to: 'sessions#get'

    get 'setup', to: "crypto#setup"
    get 'vault', to: "crypto#vault"
    post 'keypair', to: "crypto#keypair"
    put 'vault', to: "crypto#set_vault"

    get 'faq', to: "faq#index"

    post '' => 'crypto#index'
    root 'crypto#index'

end
