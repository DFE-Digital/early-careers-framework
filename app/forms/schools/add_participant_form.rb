# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include Multistep::Form

    attribute :school_cohort_id
    attribute :current_user_id
    attribute :participant_type
    attribute :type

    step :yourself do
      next_step :confirm
    end

    step :name do
      attribute :full_name

      validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }

      next_step :email
    end

    step :email do
      attribute :email

      validates :email,
                presence: { message: I18n.t("errors.email_address.blank") },
                notify_email: { allow_blank: true }

      next_step do
        if email_already_taken?
          :email_taken
        else
          :start_term
        end
      end
    end

    step :start_term do
      attribute :start_term

      validates :start_term,
                presence: { message: I18n.t("errors.start_term.blank") },
                inclusion: { in: ParticipantProfile::ECF::CURRENT_START_TERM_OPTIONS }

      next_step do
        if type == :ect && mentor_options.any?
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
      ParticipantIdentity.find_by(email: email)
        &.user
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
        self.start_term = "Autumn 2021" if start_term.nil?
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
      @current_user ||= Identity.find_user_by(id: current_user_id)
    end

    def start_term_legend
      if participant_type == :mentor
        I18n.t("schools.participants.add.start_term.mentor", full_name: full_name)
      else
        I18n.t("schools.participants.add.start_term.ect", full_name: full_name)
      end
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
        start_term: start_term,
        school_cohort: school_cohort,
        mentor_profile_id: mentor&.mentor_profile&.id,
      )
    end
  end
end
