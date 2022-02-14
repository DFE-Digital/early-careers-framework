# frozen_string_literal: true

module Multistep
  module RouteMappingExtension
    def multistep_form(route_key, form_class, controller: route_key.to_s, path: route_key.to_s, &block)
      get route_key, to: "#{controller}#start", path: path

      step_names = form_class.steps.keys
        .map(&:to_s)
        .map(&:dasherize)

      step_constraint = Regexp.union(step_names)

      scope(as: route_key, controller: controller, path: path, constraints: { step: step_constraint }) do
        instance_exec(&block) if block

        get ":step", action: :show, as: :step
        patch ":step", action: :update

        post :complete
      end
    end

    ::ActionDispatch::Routing::Mapper.include(self)
  end
end
