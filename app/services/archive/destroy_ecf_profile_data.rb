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
        # for some reason .destroy_all doesn't always seems to destroy the objects and
        # doesn't fail loudly. Don't want to use .delete_all either as we want callbacks
        # to trigger for analytics at least
        participant_profile.participant_profile_states.each(&:destroy!)
        participant_profile.participant_profile_schedules.each(&:destroy!)
        participant_profile.participant_declarations.each(&:destroy!)
        participant_profile.induction_records.each(&:destroy!)
        participant_profile.validation_decisions.each(&:destroy!)
        participant_profile.deleted_duplicates.each(&:destroy!)

        participant_profile.school_mentors.each(&:destroy!) if participant_profile.mentor?
        participant_profile.destroy!
      end
    end
  end
end
