# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    STEPS = %i[type details choose_mentor confirm not_implemented].freeze

    TYPE_OPTIONS = {
      ect: "Early Career Teacher",
      mentor: "Mentor",
    }.freeze

    attribute :completed_steps, default: []
    attribute :type
    attribute :full_name
    attribute :email
    attribute :school_cohort_id
    attribute :mentor_id

    validates :type,
              on: :type,
              presence: { message: "Please select type of the new participant" },
              inclusion: { in: TYPE_OPTIONS.keys, allow_blank: true }

    validates :full_name,
              on: :details,
              presence: true

    validates :email,
              on: :details,
              presence: true,
              format: { with: Devise.email_regexp, allow_blank: true }

    validate :email_not_taken, on: :details

    validates :mentor_id,
              on: :choose_mentor,
              presence: true,
              inclusion: { in: ->(form) { form.mentor_options.map(&:id) + %w[later] } }

    def type_options
      TYPE_OPTIONS
    end

    def mentor_options
      @mentor_options ||= school_cohort.school.mentors
    end

    def mentor
      return @mentor if defined? @mentor

      @mentor = (User.find(mentor_id) if mentor_id.present? && mentor_id != "later")
    end

    def previous_step(current_step)
      step_index = completed_steps.index(current_step)
      return completed_steps.last if step_index.nil?
      return if step_index.zero?

      completed_steps[step_index - 1]
    end

    def next_step(step)
      case step
      when :type then :details
      when :details
        if type == :ect && mentor_options.any?
          :choose_mentor
        else
          :confirm
        end
      when :choose_mentor then :confirm
      else :not_implemented
      end
    end

    def record_completed_step(step)
      completed_steps << step unless completed_steps.include? step
    end

    def completed_steps=(value)
      super(value.map(&:to_sym))
    end

    def email_already_taken?
      User.exists?(email: email)
    end

    def type=(value)
      super(value&.to_sym)
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find(school_cohort_id)
    end

  private

    def email_not_taken
      errors.add(:email, :taken) if email_already_taken?
    end

  end
end
