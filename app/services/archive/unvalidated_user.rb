# frozen_string_literal: true

module Archive
  class UnvalidatedUser < ::BaseService
    EXCLUDED_ROLES = %w[
      appropriate_body lead_provider delivery_partner admin finance induction_coordinator npq_participant npq_applicant
    ].freeze

    def call
      check_user_can_be_archived!

      data = Archive::UserSerializer.new(user).serializable_hash[:data]

      ActiveRecord::Base.transaction do
        relic = Archive::Relic.create!(object_type: user.class.name,
                                       object_id: user.id,
                                       display_name: user.full_name,
                                       reason:,
                                       data:)
        destroy_user! unless keep_original
        relic
      end
    end

  private

    attr_accessor :user, :reason, :keep_original

    def initialize(user, reason: "unvalidated/undeclared ECTs 2021 or 2022", keep_original: false)
      @user = user
      @reason = reason
      @keep_original = keep_original
    end

    def check_user_can_be_archived!
      if users_excluded_roles.any?
        raise ArchiveError, "User #{user.id} has excluded roles: #{users_excluded_roles.join(',')}"
      elsif user_has_declarations?
        raise ArchiveError, "User #{user.id} has non-voided declarations"
      elsif user_has_eligibility?
        raise ArchiveError, "User #{user.id} has an eligibility record"
      elsif user_has_mentees?
        raise ArchiveError, "User #{user.id} has mentees"
      elsif user_has_been_transferred?
        raise ArchiveError, "User #{user.id} has transfer records"
      elsif user_has_gai_id?
        raise ArchiveError, "User #{user.id} has a Get an Identity ID"
      elsif user_is_mentor_on_declarations?
        raise ArchiveError, "User #{user.id} is mentor on declarations"
      end
    end

    def users_excluded_roles
      @users_excluded_roles ||= (user.user_roles & EXCLUDED_ROLES)
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

    def destroy_user!
      user.participant_identities.each do |participant_identity|
        participant_identity.participant_profiles.each do |participant_profile|
          destroy_profile_data!(participant_profile)
        end
        participant_identity.destroy!
      end
      user.teacher_profile.destroy!
      user.destroy!
    end

    def destroy_profile_data!(participant_profile)
      DestroyECFProfileData.call(participant_profile:)
    end
  end
end
