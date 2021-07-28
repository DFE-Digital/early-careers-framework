# frozen_string_literal: true

module Schools
  class Year2020Form
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :school_id, :induction_programme_choice, :core_induction_programme_id, :full_name, :email

    validates :induction_programme_choice, presence: true, on: :choose_induction_programme
    validates :core_induction_programme_id, presence: true, on: :choose_cip

    validates :full_name, presence: true, on: :create_teacher
    validates :email,
              presence: true,
              notify_email: { allow_blank: true },
              on: :create_teacher

    def attributes
      { school_id: nil, induction_programme_choice: nil, core_induction_programme_id: nil, full_name: nil, email: nil }
    end

    def induction_programme_options
      [
        OpenStruct.new(id: "core_induction_programme", name: "Yes"),
        OpenStruct.new(id: "design_our_own", name: "No, we will support our NQTs another way"),
        OpenStruct.new(id: "no_early_career_teachers", name: "No, we don't have any NQTs"),
      ]
    end

    def school
      School.friendly.find(school_id) || School.find_by(urn: school_id)
    end

    def core_induction_programme
      CoreInductionProgramme.find(core_induction_programme_id)
    end

    def cohort
      Cohort.find_by(start_year: 2020)
    end

    def opt_out?
      induction_programme_choice == "design_our_own" || induction_programme_choice == "no_early_career_teachers"
    end

    def opt_out!
      school_cohort = SchoolCohort.find_or_initialize_by(school: school, cohort: cohort)
      school_cohort.induction_programme_choice = induction_programme_choice
      school_cohort.save!
    end

    def save!
      ActiveRecord::Base.transaction do
        school_cohort = SchoolCohort.find_or_initialize_by(school: school, cohort: cohort)
        school_cohort.induction_programme_choice = "core_induction_programme"
        school_cohort.core_induction_programme = core_induction_programme
        school_cohort.save!

        EarlyCareerTeachers::Create.call(
          full_name: full_name,
          email: email,
          school_cohort: school_cohort,
          mentor_profile_id: nil,
        )
      end
    end
  end
end
