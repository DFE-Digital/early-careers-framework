Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"
  get "/supplier_dashboard", to: "suppliers#dashboard"

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all
end
