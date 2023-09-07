# frozen_string_literal: true

module Archive
  class UnvalidatedUser < ::BaseService
    EXCLUDED_ROLES = %w[
      appropriate_body lead_provider delivery_partner admin finance induction_coordinator npq_participant npq_applicant
    ].freeze

    def call
      user_can_be_archived!

      data = Archive::UserSerializer.new(user).serializable_hash

      ActiveRecord::Base.transaction do
        relic = Archive::Relic.create!(object_type: user.class.name,
                                       object_id: user.id,
                                       display_name: user.full_name,
                                       reason: reason,
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

    def user_can_be_archived!
      if users_excluded_roles.any?
        raise ArchiveError, "User #{user.id} has excluded roles: #{users_excluded_roles.join(",")}"
      elsif user_has_declarations?
        raise ArchiveError, "User #{user.id} has non-voided declarations"
      elsif user_has_eligibility?
        raise ArchiveError, "User #{user.id} has an eligibility record"
      end
    end

    def users_excluded_roles
      @users_excluded_roles ||= (user.user_roles & EXCLUDED_ROLES)
    end

    def user_has_declarations?
      ParticipantDeclaration.not_voided.where(participant_profile_id: user.participant_profiles.select(:id)).any?
    end

    def user_has_eligibility?
      ECFParticipantEligibility.where(participant_profile_id: user.participant_profiles.select(:id)).any?
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
      participant_profile.ecf_participant_validation_data&.destroy!
      participant_profile.ecf_participant_eligibility&.destroy!
      participant_profile.participant_profile_states.destroy_all
      participant_profile.participant_profile_schedules.destroy_all
      participant_profile.participant_declarations.destroy_all
      participant_profile.induction_records.destroy_all
      participant_profile.validation_decisions.destroy_all

      destroy_mentorships!(participant_profile) if participant_profile.mentor?
      
      participant_profile.destroy!
    end

    def destroy_mentorships!(participant_profile)
      InductionRecord.active.where(mentor_profile_id: participant_profile.id).each do |induction_record|
        Induction::ChangeInductionRecord.call(induction_record:, changes: { mentor_profile_id: nil })
      end

      participant_profile.school_mentors.destroy_all
    end
  end
end
