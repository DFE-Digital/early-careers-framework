# frozen_string_literal: true

module Identity
  class TransferError < StandardError; end

  class Transfer < BaseService
    def call
      ActiveRecord::Base.transaction do
        transfer_identities!
        transfer_induction_coordinator_profile!
        transfer_get_an_identity_id!
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

    def transfer_get_an_identity_id!
      from_id = from_user.get_an_identity_id
      to_id = to_user.get_an_identity_id

      raise TransferError.new("Identity ids present on both User records: #{from_user.id} -> #{to_user.id}") if from_id.present? && to_id.present?

      if from_id.present?
        # validations prevent changes to this value under normal circumstances
        from_user.update_attribute(:get_an_identity_id, nil)
        # from_user.save(validate: false)
        to_user.update!(get_an_identity_id: from_id)
      end
    end
  end
end
