# frozen_string_literal: true

module Controller
  module RouteMappingExtension
    def appropriate_body_selection_routes(controller)
      get "appropriate-body-appointed", to: "#{controller}#appropriate_body_appointed"
      put "appropriate-body-appointed", to: "#{controller}#update_appropriate_body_appointed"

      get "appropriate-body-type", to: "#{controller}#appropriate_body_type"
      put "appropriate-body-type", to: "#{controller}#update_appropriate_body_type"

      get "appropriate-body", to: "#{controller}#appropriate_body"
      put "appropriate-body", to: "#{controller}#update_appropriate_body"
    end

    ::ActionDispatch::Routing::Mapper.include(self)
  end
end
