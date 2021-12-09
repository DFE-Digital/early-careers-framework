# frozen_string_literal: true

module Identity
  class Create < BaseService
    def call
      ActiveRecord::Base.transaction do
        find_or_create_identity
        add_participant_profiles_to_identity
      end
      identity
    end

  private

    attr_accessor :user, :origin, :identity

    def initialize(user:, origin: :ecf)
      @user = user
      @origin = origin
    end

    def find_or_create_identity
      @identity = ParticipantIdentity.find_or_create_by!(email: user.email) do |identity|
        identity.user = user
        identity.external_identifier = user.id
        identity.email = user.email
        identity.origin = origin
      end
    end

    def add_participant_profiles_to_identity
      return unless user.teacher_profile&.participant_profiles&.any?

      user.teacher_profile.participant_profiles.where(participant_identity: nil).each do |profile|
        profile.update!(participant_identity: identity)
      end
    end
  end
end
