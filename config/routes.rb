Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"
  get "check" => "application#check"

  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :school_invites, only: %i[show create]

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all
end
