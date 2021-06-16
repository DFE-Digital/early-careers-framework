# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include ActiveModel::Model
    include Multistep::Form

    TYPE_OPTIONS = {
      ect: "Early career teacher",
      mentor: "Mentor",
    }.freeze

    attribute :school_cohort_id

    step :type do
      attribute :type

      validates :type,
                presence: { message: "Please select type of the new participant" },
                inclusion: { in: TYPE_OPTIONS.keys, allow_blank: true }

      next_step :details
    end

    step :details do
      attribute :full_name
      attribute :email

      validates :full_name, presence: true

      validates :email,
                presence: true,
                notify_email: { allow_blank: true }

      next_step do
        if email_already_taken?
          :email_taken
        elsif type == :ect && mentor_options.any?
          :choose_mentor
        else
          :confirm
        end
      end
    end

    step :choose_mentor do
      attribute :mentor_id

      validates :mentor_id,
                presence: true,
                inclusion: { in: ->(form) { form.mentor_options.map(&:id) + %w[later] } }

      next_step :confirm
    end

    step :email_taken

    step :confirm

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

    def email_already_taken?
      User.exists?(email: email)
    end

    def type=(value)
      super(value&.to_sym)
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find_by(id: school_cohort_id)
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
