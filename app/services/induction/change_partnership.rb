# frozen_string_literal: true

class Induction::ChangePartnership < BaseService
  def call
    ActiveRecord::Base.transaction do
      default_induction_programme = school_cohort.default_induction_programme

      if default_induction_programme.present? &&
          default_induction_programme.full_induction_programme?

        if default_induction_programme.partnership.blank?
          # there is no partnership, we presume there was none when the school chose FIP
          # so we can just update the programme
          default_induction_programme.update!(partnership:)
          move_unpartnered_participants

        elsif default_induction_programme.partnership != partnership &&
            default_induction_programme.partnership.challenged?

          # existing FIP partnership replaced so create a new programme and migrate
          # all the participants to the new one
          programme = InductionProgramme.create!(school_cohort:,
                                                 training_programme: "full_induction_programme",
                                                 partnership:)

          Induction::MigrateParticipantsToNewProgramme.call(from_programme: default_induction_programme,
                                                            to_programme: programme)

          school_cohort.update!(default_induction_programme: programme)
          move_unpartnered_participants
        end
      else
        Induction::SetCohortInductionProgramme.call(school_cohort:, programme_choice: "full_induction_programme")
        move_unpartnered_participants
      end
    end
  end

private

  attr_reader :school_cohort, :partnership

  def initialize(school_cohort:, partnership:)
    @school_cohort = school_cohort
    @partnership = partnership
  end

  def move_unpartnered_participants
    unpartnered_fip_programmes.each do |programme|
      Induction::MigrateParticipantsToNewProgramme.call(from_programme: programme,
                                                        to_programme: school_cohort.default_induction_programme)
    end
  end

  def unpartnered_fip_programmes
    school_cohort
      .induction_programmes
      .full_induction_programme
      .joins(:active_induction_records)
      .left_joins(:partnership)
      .where("partnerships.id IS NULL OR partnerships.challenged_at IS NOT NULL")
  end
end
