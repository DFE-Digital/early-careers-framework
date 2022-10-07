# frozen_string_literal: true

module Identity
  class Create < BaseService
    def call
      ActiveRecord::Base.transaction do
        find_or_create_identity!
        add_participant_profiles_to_identity
      end
      identity
    end

  private

    attr_accessor :user, :origin, :identity, :email, :alternate_login

    def initialize(user:, origin: :ecf, email: nil)
      @user = user
      @origin = origin
      @email = email || user.email
    end

    def find_or_create_identity!
      email_user = Identity.find_user_by(email:)
      raise "Email already taken" if email_user.present? && email_user != user

      @identity = ParticipantIdentity.find_or_create_by!(email:) do |identity|
        identity.user = user
        identity.external_identifier = external_id
        identity.email = email
        identity.origin = origin
      end
    end

    def add_participant_profiles_to_identity
      return unless user.teacher_profile&.participant_profiles&.any?

      user.teacher_profile.participant_profiles.where(participant_identity: nil).each do |profile|
        profile.update!(participant_identity: identity)
      end
    end

    def external_id
      # if we want to create an alternate email / sign in for a participant
      # it cannot have the same external_identifier as their existing one
      if ParticipantIdentity.exists?(external_identifier: user.id)
        SecureRandom.uuid
      else
        user.id
      end
    end
  end
end
