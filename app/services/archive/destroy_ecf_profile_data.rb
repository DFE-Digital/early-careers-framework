# frozen_string_literal: true

# !! ATTENTION !!
#
# This is DANGEROUS. Please DO NOT use this in production unless you are 100% sure you need to
# remove a ParticipantProfile record and its associated objects and have CONFIRMATION
# it is OK to do so.
#
# Ensure an archive has been made BEFORE using this if there needs to be one
#
# This service is BRUTAL and HEARTLESS and will revel in your misery if you make a mistake.
#
module Archive
  class DestroyECFProfileData < ::BaseService
    def call
      if profile_has_mentees?
        raise ArchiveError, "Profile #{participant_profile.id} has mentees"
      else
        destroy_profile!
      end
    end

  private

    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def profile_has_mentees?
      participant_profile.mentor? && InductionRecord.where(mentor_profile: participant_profile).any?
    end

    def destroy_profile!
      ActiveRecord::Base.transaction do
        participant_profile.ecf_participant_validation_data&.destroy!
        participant_profile.ecf_participant_eligibility&.destroy!
        participant_profile.participant_profile_states.destroy_all
        participant_profile.participant_profile_schedules.destroy_all
        participant_profile.participant_declarations.destroy_all
        participant_profile.induction_records.destroy_all
        participant_profile.validation_decisions.destroy_all
        participant_profile.deleted_duplicates.destroy_all

        participant_profile.school_mentors.destroy_all if participant_profile.mentor?
        participant_profile.destroy!
      end
    end
  end
end
