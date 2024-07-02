# frozen_string_literal: true

module Archive
  module SupportMethods
    EXCLUDED_ROLES = %w[
      appropriate_body lead_provider delivery_partner admin finance induction_coordinator npq_participant npq_applicant
    ].freeze

    def profile_has_declarations?
      participant_profile.participant_declarations.not_voided.any?
    end

    def profile_has_eligibility?
      participant_profile.ecf_participant_eligibility.present?
    end

    def profile_has_mentees?
      participant_profile.mentor? && InductionRecord.where(mentor_profile: participant_profile).any?
    end

    def destroy_profile!(participant_profile)
      DestroyECFProfileData.call(participant_profile:)
    end

    def user_has_declarations?
      profile_ids = user.participant_profiles.pluck(:id)
      # handle bad data case where user_id might be on declarations not associated with the users profiles
      # in this case it doesn't matter whether they're voided or not, removing the user will cause issues.
      ParticipantDeclaration.not_voided.where(participant_profile_id: profile_ids).any? ||
        ParticipantDeclaration.where(user_id: user.id).where.not(participant_profile_id: profile_ids).any?
    end

    def user_has_eligibility?
      ECFParticipantEligibility.where(participant_profile_id: user.participant_profiles.select(:id)).any?
    end

    def user_has_mentees?
      return false unless user.user_roles.include? "mentor"

      user.teacher_profile.participant_profiles.mentors.any? do |mentor_profile|
        InductionRecord.where(mentor_profile:).any?
      end
    end

    def user_has_been_transferred?
      user.participant_id_changes.any?
    end

    def user_has_gai_id?
      user.get_an_identity_id.present?
    end

    def user_is_mentor_on_declarations?
      ParticipantDeclaration.where(mentor_user_id: user.id).any?
    end

    def users_excluded_roles
      user.user_roles & EXCLUDED_ROLES
    end

    def destroy_user!
      user.participant_identities.each do |participant_identity|
        participant_identity.participant_profiles.each do |participant_profile|
          destroy_profile!(participant_profile)
        end
        participant_identity.destroy!
      end
      user.teacher_profile.destroy!
      user.destroy!
    end
  end
end
