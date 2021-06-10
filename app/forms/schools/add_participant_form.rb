# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    STEPS = %i[type details confirm not_implemented].freeze

    TYPE_OPTIONS = {
      ect: "Early Career Teacher",
      mentor: "Mentor",
    }.freeze

    attribute :completed_steps, default: []
    attribute :type
    attribute :full_name
    attribute :email

    validates :type,
              on: :type,
              presence: { message: "Please select type of the new participant" },
              inclusion: { in: TYPE_OPTIONS.keys.map(&:to_s), allow_blank: true }

    validates :full_name,
              on: :details,
              presence: true

    validates :email,
              on: :details,
              presence: true,
              format: { with: Devise.email_regexp, allow_blank: true }

    def type_options
      TYPE_OPTIONS
    end

    def previous_step(current_step)
      step_index = completed_steps.index(current_step)
      return completed_steps.last if step_index.nil?
      return if step_index.zero?

      completed_steps[step_index - 1]
    end

    def next_step(step)
      STEPS[STEPS.index(step) + 1]
    end

    def record_completed_step(step)
      completed_steps << step unless completed_steps.include? step
    end

    def completed_steps=(value)
      super(value.map(&:to_sym))
    end
  end
end
