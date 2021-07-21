# frozen_string_literal: true

module Schools
  class Year2020Form
    include ActiveModel::Model
    include Multistep::Form

    attribute :school_id

    step :start do
      next_step do
        :select_cip
      end
    end

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
      User.find_by(email: email)&.participant_profiles&.ecf&.any?
    end

    def save!
      school_cohort = SchoolCohort.find_or_create_by!(school_id: school_id, cohort: Cohort.find_by(start_year: 2020)) do |new_school_cohort|
        new_school_cohort.update!(induction_programme_choice: "core_induction_programme")
      end

      EarlyCareerTeachers::Create.call(
        full_name: full_name,
        email: email,
        school_cohort: school_cohort,
        mentor_profile_id: nil,
      )
    end
  end
end
