# frozen_string_literal: true

module Admin
  class ChangeInductionService
    def initialize(school:, cohort:)
      @school = school
      @cohort = cohort
    end

    def change_induction_provision(new_provision)
      school_cohort
      perform_induction_change(new_provision) and return if school_cohort.nil?

      if school_cohort.full_induction_programme?
        raise ArgumentError, "Cannot change induction programme for a partnered school" if school.partnered?(cohort)

        withdraw_participants_if_required(new_provision)
      end

      if school_cohort.core_induction_programme?
        withdraw_participants_if_required(new_provision)
        school_cohort.update!(core_induction_programme: nil)
      end

      perform_induction_change(new_provision)
    end

    def change_cip_materials(new_materials)
      raise ArgumentError, "Can only select materials for CIP schools" unless school_cohort.core_induction_programme?

      school_cohort.update!(core_induction_programme: new_materials)
    end

  private

    attr_reader :school, :cohort

    def school_cohort
      @school_cohort ||= SchoolCohort.find_by(school: school, cohort: cohort)
    end

    def perform_induction_change(new_provision)
      if school_cohort
        school_cohort.update!(induction_programme_choice: new_provision)
      else
        SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: new_provision)
      end
    end

    def withdraw_participants_if_required(new_provision)
      return if %i[core_induction_programme full_induction_programme].include? new_provision

      school_cohort.active_ecf_participant_profiles.each(&:permanently_inactive!)
    end
  end
end
