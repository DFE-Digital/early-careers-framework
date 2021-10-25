# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include Multistep::Form

    attribute :school_cohort_id
    attribute :current_user_id
    attribute :participant_type

    step :type do
      attribute :type

      validates :type,
                presence: { message: "Please select type of the new participant" },
                inclusion: { in: :type_options, allow_blank: true }

      next_step do
        type == :self ? :yourself : :name
      end
    end

    step :yourself do
      next_step :confirm
    end

    step :name do
      attribute :full_name

      validates :full_name, presence: { message: "Enter a full name" }

      next_step :email
    end

    step :email do
      attribute :email

      validates :email,
                presence: { message: "Enter an email address" },
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
                if: -> { type == :ect },
                inclusion: { in: ->(form) { form.mentor_options.map(&:id) + %w[later] } }

      next_step :confirm
    end

    step :email_taken

    step :confirm

    def type_options
      [
        :ect,
        :mentor,
        (:self if can_add_self?),
      ].compact
    end

    def can_add_self?
      !current_user.mentor?
    end

    def mentor_options
      @mentor_options ||= school_cohort.active_mentors.order(:full_name)
    end

    def mentor
      return @mentor if defined? @mentor

      @mentor = (User.find(mentor_id) if mentor_id.present? && mentor_id != "later")
    end

    def email_already_taken?
      User.find_by(email: email)
        &.teacher_profile
        &.participant_profiles
        &.active_record
        &.ecf
        &.any?
    end

    def type=(value)
      reset_steps(:name, :email, :choose_mentor) if value.to_s != type

      super(value&.to_sym)
      if type == :self
        self.full_name = current_user.full_name
        self.email = current_user.email
        self.participant_type = :mentor
      else
        self.participant_type = type
      end
    end

    def participant_type=(value)
      super(value&.to_sym)
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find_by(id: school_cohort_id)
    end

    def current_user
      @current_user ||= User.find_by(id: current_user_id)
    end

    def creators
      {
        ect: EarlyCareerTeachers::Create,
        mentor: Mentors::Create,
      }
    end

    def save!
      creators[participant_type].call(
        full_name: full_name,
        email: email,
        school_cohort: school_cohort,
        mentor_profile_id: mentor&.mentor_profile&.id,
      )
    end
  end
end
