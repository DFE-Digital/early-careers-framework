# frozen_string_literal: true

module Schools
  class AddParticipantWizard
    include ActiveModel::Model

    class InvalidStep < StandardError; end

    attr_reader :current_step, :submitted_params, :current_state, :request, :current_user

    def initialize(current_step:, current_state:, current_user:, submitted_params: {})
      set_current_step(current_step)

      @current_user = current_user
      @current_state = current_state
      @submitted_params = submitted_params

      load_current_user_into_current_state
    end

    def self.permitted_params_for(step)
      "Schools::AddParticipantWizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
    end

    def before_render
      form.before_render
    end

    def after_render
      form.after_render
    end

    def form
      @form ||= build_form
    end

    def save!
      form.attributes.each do |k, v|
        current_state[k.to_s] = v
      end

      form.after_save
    end

    def next_step_path
      form.next_step.to_s.dasherize
    end

    def previous_step_path
      form.previous_step.to_s.dasherize
    end

    def skip_step?
      form.skip_step?
    end

    def form_for_step(step)
      step_form_class = form_class_for(step)
      hash = current_state.slice(*step_form_class.permitted_params.map(&:to_s))
      hash.merge!(wizard: self)
      step_form_class.new(hash)
    end

    def ect_participant?
      current_state["participant_type"] == "ect"
    end

  private

    def load_current_user_into_current_state
      current_state["current_user"] = current_user
    end

    def load_from_current_state
      current_state.slice(*form_class.permitted_params.map(&:to_s))
    end

    def form_class
      @form_class ||= form_class_for(current_step)
    end

    def form_class_for(step)
      "#{self.class.name}Steps::#{step.to_s.camelcase}Step".constantize
    end

    def build_form
      hash = load_from_current_state
      hash.merge!(submitted_params)
      hash.merge!(wizard: self)

      form_class.new(hash)
    end

    def set_current_step(step)
      @current_step = steps.find { |s| s == step.to_sym }

      raise InvalidStep, "Could not find step: #{step}" if @current_step.nil?
    end

    def steps
      %i[
        who
        what_we_need
        check_answers
        confirmation
      ]
    end
  end
end
