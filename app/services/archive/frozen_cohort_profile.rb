# frozen_string_literal: true

module Archive
  class FrozenCohortProfile < ::BaseService
    include Archive::SupportMethods

    def call
      check_profile_can_be_archived!

      data = Archive::ParticipantProfileSerializer.new(participant_profile).serializable_hash[:data]

      ActiveRecord::Base.transaction do
        relic = Archive::Relic.create!(object_type: participant_profile.class.name,
                                       object_id: participant_profile.id,
                                       display_name: user.full_name,
                                       reason:,
                                       data:)
        destroy_profile!(participant_profile) unless keep_original
        relic
      end
    end

  private

    attr_accessor :participant_profile, :user, :reason, :keep_original

    def initialize(participant_profile, reason: "undeclared participants in frozen cohort", keep_original: false)
      @participant_profile = participant_profile
      @user = participant_profile.user
      @reason = reason
      @keep_original = keep_original
    end

    def check_profile_can_be_archived!
      if profile_not_archivable_from_cohort?
        raise ArchiveError, "Profile #{participant_profile.id} cannot be archived from the #{cohort.start_year} cohort"
      end
    end

    def profile_not_archivable_from_cohort?
      !participant_profile.archivable_from_frozen_cohort?
    end

    def cohort
      @cohort ||= participant_profile.schedule.cohort
    end
  end
end
