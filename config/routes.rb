Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "saude#index"
  resources :users, only: %i[new create], path: "cadastro"
  get "login", to: "sessions#new", as: :login
  
  # ----------------
  # Autenticação de Funcionário
  # ----------------
  namespace :operador do
    get    "entrar", to: "sessoes#new",     as: :entrar
    post   "entrar", to: "sessoes#create"
    delete "sair",   to: "sessoes#destroy", as: :sair
    
    # Outras rotas do operador previstas no Spike (Issues #5, #6, #7)
    resource  :ponto,      only: [:show, :update], controller: "pontos_acesso"
    resource  :terminal,   only: [:show],          controller: "terminal"
    resources :validacoes, only: [:create]
    resources :historico,  only: [:index]
  end
  
  namespace :admin do
    get "relatorio", to: "relatorios#show", as: :relatorio
    resources :restaurantes, except: [:destroy]
    resources :catracas, only: [:create, :update]
  end
  # ----------------

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
