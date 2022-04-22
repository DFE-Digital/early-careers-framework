# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include Multistep::Form

    attribute :school_cohort_id
    attribute :current_user_id
    attribute :participant_type
    attribute :type
    attribute :dqt_record

    step :yourself do
      next_step :confirm
    end

    step :started do
      next_step :name
    end

    step :name do
      attribute :full_name

      validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }
      before_complete { validate_dqt_record if check_for_dqt_record? }

      next_step do
        if dqt_record.present?
          :email
        elsif check_for_dqt_record?
          :cannot_find_their_details
        else
          :do_you_know_teachers_trn
        end
      end
    end

    step :do_you_know_teachers_trn do
      attribute :do_you_know_teachers_trn
      validates :do_you_know_teachers_trn,
                presence: true,
                inclusion: { in: %w[true false] }
      next_step do
        if trn_known?
          :trn
        else
          :email
        end
      end
    end

    step :trn do
      attribute :trn, :string

      validates :trn,
                presence: true,
                format: { with: /\A\d+\z/ },
                length: { within: 5..7 }
      before_complete { validate_dqt_record if check_for_dqt_record? }
      next_step do
        if dqt_record.present?
          :email
        elsif check_for_dqt_record?
          :cannot_find_their_details
        else
          :dob
        end
      end
    end

    step :dob, update: true do
      attribute :dob, :date
      validates :dob,
                presence: true,
                inclusion: {
                  in: ->(_) { (Date.new(1900, 1, 1))..(Date.current - 18.years) },
                  message: :invalid,
                }

      before_complete { validate_dqt_record if check_for_dqt_record? }
      next_step do
        if dqt_record.present?
          :email
        else
          :cannot_find_their_details
        end
      end
    end

    step :email do
      attribute :email

      validates :email,
                presence: { message: I18n.t("errors.email_address.blank") },
                notify_email: { allow_blank: true }

      before_complete { remove_trn_and_dob unless trn_known? }
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
                presence: { message: I18n.t("errors.start_term.blank") }

      next_step :start_date
    end

    step :start_date, update: true do
      attribute :start_date, :date
      validates :start_date,
                presence: true,
                inclusion: {
                  in: ->(_) { (Date.current - 1.year)..(Date.current + 1.year) },
                  message: :invalid,
                }

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

    step :cannot_find_their_details

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
      @mentor_options ||= if FeatureFlag.active?(:multiple_cohorts)
                            school_cohort.school.mentors
                          else
                            school_cohort.active_mentors.order(:full_name)
                          end
    end

    def mentor
      return @mentor if defined? @mentor

      @mentor = (User.find(mentor_id) if mentor_id.present? && mentor_id != "later")
    end

    def trn_known?
      do_you_know_teachers_trn == "true"
    end

    def validate_dqt_record
      self.dqt_record = ParticipantValidationService.validate(
        full_name: full_name,
        trn: trn,
        date_of_birth: dob,
        config: {
          check_first_name_only: true,
        },
      )
    end

    def check_for_dqt_record?
      full_name.present? && trn.present? && dob.present?
    end

    def remove_trn_and_dob
      self.dob = nil
      self.trn = nil
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
        self.start_term = default_start_term if start_term.nil?
        self.start_date = Time.zone.now
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

    def default_start_term
      school_cohort.cohort.start_term_options.first
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
      ActiveRecord::Base.transaction do
        profile = creators[participant_type].call(
          full_name: full_name,
          email: email,
          start_term: start_term,
          school_cohort: school_cohort,
          mentor_profile_id: mentor&.mentor_profile&.id,
          start_date: start_date,
        )
        store_validation_result!(profile) if dqt_record.present?
        profile
      end
    end

    def store_validation_result!(profile)
      ::Participants::ParticipantValidationForm.call(
        profile,
        data: {
          trn: trn,
          nino: nil,
          date_of_birth: dob,
          full_name: full_name,
        },
      )
    end
  end
end
