# frozen_string_literal: true

module Archive
  class FrozenCohortUser < ::BaseService
    include Archive::SupportMethods

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

    def initialize(user, reason: "undeclared participants in frozen cohort", keep_original: false)
      @user = user
      @reason = reason
      @keep_original = keep_original
    end

    def check_user_can_be_archived!
      if users_excluded_roles.any?
        raise ArchiveError, "User #{user.id} has excluded roles: #{users_excluded_roles.join(',')}"
      elsif user_profiles_are_not_all_archivable?
        raise ArchiveError, "User #{user.id} has profiles in non-frozen cohorts"
      elsif user_is_on_other_declarations?
        raise ArchiveError, "User #{user.id} is associated with declarations on other profiles"
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

    def user_profiles_are_not_all_archivable?
      !user.participant_profiles.ecf.all?(&:archivable_from_frozen_cohort?)
    end

    def user_is_on_other_declarations?
      # handle bad data case where user_id might be on declarations not associated with the users profiles
      # in this case it doesn't matter whether they're voided or not, removing the user will cause issues.
      ParticipantDeclaration.where(user_id: user.id).where.not(participant_profile_id: user.participant_profiles.select(:id)).any?
    end
  end
end
