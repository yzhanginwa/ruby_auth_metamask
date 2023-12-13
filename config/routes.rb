RubyAuthMetamask::Engine.routes.draw do
  get 'signin', to: 'users#signin'
  post 'signin', to: 'users#verify'
end
