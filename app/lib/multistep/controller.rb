# frozen_string_literal: true

module Multistep
  module Controller
    extend ActiveSupport::Concern

    class_methods do
      def form(value = nil, as: nil) # rubocop:disable Naming/MethodParameterName
        if value
          @form = value
          if as
            alias_method as, :form
            helper_method as
          end
        else
          @form
        end
      end

      def session_key(value = nil)
        if value
          @session_key = value
        else
          @session_key ||= @form && @form.model_name.param_key
        end
      end

      def params_key(value = nil)
        if value
          @params_key = value
        else
          @params_key ||= @form && @form.model_name.param_key
        end
      end

      def abandon_journey_path(&block)
        if block
          @abandon_journey_path = block
        else
          @abandon_journey_path || raise("Abandon path not defined!")
        end
      end

      def setup_form(&block)
        if block
          @setup_form = block
        else
          @setup_form
        end
      end

      def result(as: name) # rubocop:disable Naming/MethodParameterName
        alias_method as, :result
        helper_method as
      end
    end

    included do
      helper_method :back_link_path
      before_action :ensure_form_present, only: %i[show update complete]
      after_action :remove_form, only: :complete
    end

    attr_reader :result

    def start
      reset_form
      redirect_to action: :show, step: form.next_step
    end

    def show
      render current_step
    end

    def update
      form.assign_attributes(form_params)

      if form.valid?(current_step)
        form.record_completed_step current_step
        store_form_in_session
        redirect_to action: :show, step: step_param(form.next_step)
      else
        render current_step
      end
    end

    def complete
      @result = form.save!
    end

  private

    def reset_form
      session.delete(self.class.session_key)
      form = self.class.form.new
      setup_form(form)
      @form = form
      store_form_in_session
    end

    def setup_form(form)
      return unless (setup = self.class.setup_form)

      instance_exec(form, &setup)
    end

    def form
      @form ||= self.class.form.new(session[self.class.session_key])
    end

    def store_form_in_session
      session[self.class.session_key] = form.attributes
    end

    def current_step
      params[:step].underscore.to_sym
    end

    def back_link_path
      previous_step = form.previous_step(from: current_step)
      return abandon_journey_path unless previous_step

      { action: :show, step: step_param(previous_step) }
    end

    def form_params
      attributes = form.class.steps[current_step].attributes
      params[self.class.params_key]&.permit(*attributes) || {}
    end

    def ensure_form_present
      redirect_to escape_route unless session.key?(self.class.session_key)
    end

    def abandon_journey_path
      instance_exec(&self.class.abandon_journey_path)
    end

    def step_param(step)
      step.to_s.dasherize
    end

    def remove_form
      session.delete(self.class.session_key)
    end
  end
end
