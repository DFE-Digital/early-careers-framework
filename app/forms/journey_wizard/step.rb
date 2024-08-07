# frozen_string_literal: true

module JourneyWizard
  class Step
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :wizard

    def after_render; end
    def after_save; end

    def attributes
      self.class.permitted_params.index_with do |key|
        public_send(key)
      end
    end

    def before_render; end
    def before_save; end

    # If the execution (POST request) of this step completes the journey.
    # Note that there might be a final next step to visit (only GET).
    def complete?
      false
    end

    # Check the requirements to determine if this step is a valid successor of the last visited.
    def expected?
      false
    end

    def next_step
      raise NotImplementedError
    end

    # indicates that the journey is complete and any saving/updating should occur (normally followed by a "complete" page)
    def journey_complete?
      false
    end

    def self.permitted_params
      []
    end

    # when changing an answer from a check-answers page, sometimes it is desirable to
    # revisit the subsequent step and not return immediately on submission
    def revisit_next_step?
      false
    end

    # provide ability to have valid end of journey paths
    # if choice made when changing a value does not permit continuing
    # to the return point
    def evaluate_next_step_on_change?
      false
    end

    def terminal_step?
      next_step == :none
    end

    # Module::Group::AmazingThingStep => "amazing_thing"
    def view_name
      self.class.name.demodulize.delete_suffix("Step").underscore
    end
  end
end
