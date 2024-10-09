# frozen_string_literal: true

module Identity
  class Transfer < BaseService
    def call
      return if to_user == from_user
      return unless [to_user, from_user].all?(&:present?)

      ActiveRecord::Base.transaction do
        transfer_identities!
        transfer_induction_coordinator_profile!
        transfer_get_an_identity_id!
        create_participant_id_change!
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
        identity.participant_profiles.each do |participant_profile|
          participant_profile.update!(teacher_profile:)
          transfer_declarations!(participant_profile:)
        end
      end
    end

    def transfer_induction_coordinator_profile!
      if from_user.induction_coordinator?
        if to_user.induction_coordinator?
          to_profile = to_user.induction_coordinator_profile
          InductionCoordinatorProfilesSchool.where(induction_coordinator_profile: from_user.induction_coordinator_profile).find_each do |profiles_school|
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

      if from_id.present?
        # validations prevent changes to this value under normal circumstances
        from_user.update_attribute(:get_an_identity_id, nil) # rubocop:disable Rails/SkipsModelValidations
        to_user.update_attribute(:get_an_identity_id, from_id) if to_id.blank? || from_user.created_at > to_user.created_at # rubocop:disable Rails/SkipsModelValidations
      end
    end

    def transfer_declarations!(participant_profile:)
      return unless participant_profile.participant_declarations

      participant_profile.participant_declarations.update!(user: to_user)
    end

    def create_participant_id_change!
      # Move previous change history to new to_user
      from_user.participant_id_changes.update!(user: to_user)

      to_user.participant_id_changes.find_or_create_by!(from_participant: from_user, to_participant: to_user)
    end
  end
end
