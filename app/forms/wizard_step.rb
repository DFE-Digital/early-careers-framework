# frozen_string_literal: true

class WizardStep
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :wizard

  def self.permitted_params
    []
  end

  def next_step
    raise NotImplementedError
  end

  # indicates that the journey is complete and any saving/updating should occur (normally followed by a "complete" page)
  def journey_complete?
    false
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

  def before_render; end

  def view_name
    # remove any module scope and 'Step' suffix from the class name as default view name for the step
    # e.g. for Module::Group::AmazingThingStep we get "amazing_thing" back
    # This can be overridden in steps that need to support multiple views.
    self.class.name.demodulize.delete_suffix("Step").underscore
  end

  def after_render; end

  def before_save; end
  def after_save; end

  def attributes
    self.class.permitted_params.index_with do |key|
      public_send(key)
    end
  end
end
