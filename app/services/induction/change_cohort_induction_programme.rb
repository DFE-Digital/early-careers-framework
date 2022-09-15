# frozen_string_literal: true

class Induction::ChangeCohortInductionProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      previous_programme = school_cohort.default_induction_programme

      if !force && previous_programme&.full_induction_programme? && previous_programme&.partnership&.active?
        raise ArgumentError, "Cannot change induction programme for a partnered school"
      end

      Induction::SetCohortInductionProgramme.call(school_cohort:,
                                                  programme_choice:,
                                                  opt_out_of_updates: programme_choice == "no_early_career_teachers",
                                                  core_induction_programme:)

      new_programme = school_cohort.default_induction_programme

      if previous_programme.present? && new_programme.present?
        Induction::MigrateParticipantsToNewProgramme.call(from_programme: previous_programme,
                                                          to_programme: new_programme)
      end
    end
  end

private

  attr_reader :school_cohort, :programme_choice, :opt_out_of_updates, :core_induction_programme, :force

  def initialize(school_cohort:, programme_choice:, core_induction_programme: nil, force: false)
    @school_cohort = school_cohort
    @programme_choice = programme_choice.to_s
    @core_induction_programme = core_induction_programme
    @force = force
  end
end
