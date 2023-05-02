# frozen_string_literal: true

class WizardRouter
  module RouteMappingExtension
    def wizard_scope(controller, route_key: controller, path: route_key.to_s.dasherize, &block)
      scope(as: route_key, controller:, path:) do
        instance_exec(&block) if block_given?

        get ":step", to: "#{controller}#show", as: :show
        get ":step/change", to: "#{controller}#show", as: :show_change, changing_answer: "1"
        put ":step", to: "#{controller}#update", as: :update
      end
    end

    ::ActionDispatch::Routing::Mapper.include(self)
  end
end
