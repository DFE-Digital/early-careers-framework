# frozen_string_literal: true

class Induction::ChangeCoreInductionProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      default_induction_programme = school_cohort.default_induction_programme

      if default_induction_programme.present? && default_induction_programme.core_induction_programme?
        if default_induction_programme.core_induction_programme.blank?
          default_induction_programme.update!(core_induction_programme: core_induction_programme)
          school_cohort.update!(core_induction_programme: core_induction_programme)
        elsif default_induction_programme.core_induction_programme != core_induction_programme
          # existing CIP materials replaced so create a new programme and migrate
          # all the participants to the new one
          programme = InductionProgramme.create!(school_cohort: school_cohort,
                                                 training_programme: "core_induction_programme",
                                                 core_induction_programme: core_induction_programme)

          Induction::MigrateParticipantsToNewProgramme.call(from_programme: default_induction_programme,
                                                            to_programme: programme)

          school_cohort.update!(default_induction_programme: programme, core_induction_programme: core_induction_programme)
        end
      end
    end
  end

private

  attr_reader :school_cohort, :core_induction_programme

  def initialize(school_cohort:, core_induction_programme:)
    @school_cohort = school_cohort
    @core_induction_programme = core_induction_programme
  end
end
