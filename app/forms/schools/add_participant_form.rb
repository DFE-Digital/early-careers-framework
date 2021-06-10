# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    STEPS = %i[type details choose_mentor email_taken confirm not_implemented].freeze

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
              notify_email: { allow_blank: true }

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
        return :email_taken if email_already_taken?

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
      if completed_steps.include? step
        self.completed_steps = completed_steps[0..completed_steps.index(step)]
      else
        completed_steps << step
      end
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

    def save!
      ActiveRecord::Base.transaction do
        user = User.create!(full_name: full_name, email: email)

        profile_class = type == :ect ? EarlyCareerTeacherProfile : MentorProfile
        profile = profile_class.new(
          user: user,
          school_id: school_cohort.school_id,
          cohort_id: school_cohort.cohort_id,
        )
        profile.mentor_profile = mentor&.mentor_profile if type == :ect
        profile.tap(&:save!)
      end
    end
  end
end
