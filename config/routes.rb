RubyAuthMetamask::Engine.routes.draw do
  get  'signin', to: 'users#signin', as: 'signin'
  post 'verify', to: 'users#verify', as: 'verify'

  root           to: 'users#signin'
end
