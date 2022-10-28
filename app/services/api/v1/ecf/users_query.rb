# frozen_string_literal: true

module Api::V1::ECF
  class UsersQuery
    attr_reader :updated_since, :email

    def initialize(updated_since: nil, email: nil)
      @updated_since = updated_since
      @email         = email
    end

    def all
      users = User
        .where(id: ParticipantProfile::ECF.joins(:teacher_profile).select("teacher_profiles.user_id"))
        .includes(teacher_profile: {
          ecf_profiles: [
            :core_induction_programme,
            { school_cohort: :cohort },
          ],
        })

      if updated_since.present?
        users = users.changed_since(updated_since)
      end

      if email.present?
        users = users.joins(:participant_identities).where(participant_identities: { email: })
      end

      users
    end
  end
end
