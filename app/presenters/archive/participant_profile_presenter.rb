# frozen_string_literal: true

module Archive
  class ParticipantProfilePresenter < RelicPresenter
    def ecf?
      attribute(:type).in? %w[ParticipantProfile::ECT ParticipantProfile::Mentor]
    end

    def sparsity_uplift?
      attribute(:sparsity_uplift)
    end

    def pupil_premium_uplift?
      attribute(:pupil_premium_uplift)
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find(attribute(:school_cohort_id))
    end

    def schedule
      @schedule ||= Finance::Schedule.find(attribute(:schedule_id))
    end

    def created_at
      Time.zone.parse(attribute(:created_at))
    end

    def induction_records
      InductionRecord.none
    end

    def participant_declarations
      ParticipantDeclaration.none
    end
  end
end
