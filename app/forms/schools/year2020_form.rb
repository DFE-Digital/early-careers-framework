# frozen_string_literal: true

module Schools
  class Year2020Form
    include ActiveModel::Model
    include Multistep::Form

    attribute :school_cohort_id
    attribute :current_user_id
    attribute :participant_type

    step :start do
      next_step do
        :select_cip
      end
    end
    # QQQQ let users quit forever in this step

    step :select_cip do
      attribute :core_induction_programme_id

      validates :core_induction_programme_id, presence: true

      next_step do
        :details
      end
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
        else
          :confirm
        end
      end
    end

    step :email_taken

    step :confirm

    def email_already_taken?
      User.exists?(email: email)
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find_by(id: school_cohort_id)
    end

    def current_user
      @current_user ||= User.find_by(id: current_user_id)
    end

    def save!
      EarlyCareerTeachers::Create.call(
        full_name: full_name,
        email: email,
        cohort_id: school_cohort.cohort_id,
        school_id: school_cohort.school_id,
        mentor_profile_id: nil,
      )
    end
  end
end
