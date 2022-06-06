# frozen_string_literal: true

module Identity
  class Transfer < BaseService
    def call
      ActiveRecord::Base.transaction do
        transfer_identities!
        transfer_induction_coordinator_profile!
      end
    end

  private

    attr_accessor :from_user, :to_user

    def initialize(from_user:, to_user:)
      @from_user = from_user
      @to_user = to_user
    end

    def transfer_identities!
      teacher_profile = TeacherProfile.find_or_create_by!(user: to_user)

      from_user.participant_identities.each do |identity|
        identity.update!(user: to_user)
        identity.participant_profiles.each do |profile|
          profile.update!(teacher_profile:)
        end
      end
    end

    def transfer_induction_coordinator_profile!
      if from_user.induction_coordinator?
        if to_user.induction_coordinator?
          to_profile = to_user.induction_coordinator_profile
          InductionCoordinatorProfilesSchool.where(induction_coordinator_profile: from_user.induction_coordinator_profile).each do |profiles_school|
            profiles_school.update!(induction_coordinator_profile: to_profile)
          end
        else
          from_user.induction_coordinator_profile.update!(user: to_user)
        end
      end
    end
  end
end
