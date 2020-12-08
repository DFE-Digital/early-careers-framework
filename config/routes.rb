Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
  }

  devise_scope :user do
    get "email_confirmation", to: "users/sessions#redirect_from_magic_link"
    post "sign_in_with_token", to: "users/sessions#sign_in_with_token"
  end

  get "/pages/:page", to: "pages#show"
  get "check" => "application#check"

  resource :dashboard, controller: :dashboard, only: :show
  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :school_invites, only: %i[show create]

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  root to: "pages#home"
end
