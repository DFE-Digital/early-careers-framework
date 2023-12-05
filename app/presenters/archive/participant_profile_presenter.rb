# frozen_string_literal: true

module Archive
  class ParticipantProfilePresenter < RelicPresenter

    def ecf?
      profile_type.in? %w[ParticipantProfile::ECT ParticipantProfile::Mentor]
    end

    def profile_type
      attribute(:type)
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

    def induction_records
      @induction_records ||= InductionRecordPresenter.wrap(attribute("induction_records")).sort_by(&:start_date).reverse
    end

    def participant_declarations
      @participant_declarations ||= ParticipantDeclarationPresenter.wrap(attribute("participant_declarations")).sort_by(&:declaration_date)
    end

    def created_at
      Time.zone.parse(attribute(:created_at))
    end
  end
end
