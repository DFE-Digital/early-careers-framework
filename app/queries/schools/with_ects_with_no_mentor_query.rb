# frozen_string_literal: true

module Schools
  class WithEctsWithNoMentorQuery < BaseService
    def call
      ParticipantProfile::ECT.joins(:user,
                                    :ecf_participant_eligibility,
                                    current_induction_records: {
                                      school: :induction_coordinators,
                                    })
                             .where(mentor_profile_id: nil, status: :active, training_status: :active)
                             .where.not(ecf_participant_eligibilities: { status: :ineligible })
                             .group_by do |ect|
        ect.latest_current_induction_record.school
      end
    end
  end
end
