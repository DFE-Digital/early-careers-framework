# frozen_string_literal: true

module Archive
  class UnvalidatedUser < ::BaseService
    def call
      return unless user_can_be_archived?

      data = Archive::UserSerializer.new(user).serializable_hash

      ActiveRecord::Base.transaction do
        relic = Archive::Relic.create!(object_type: user.class.name,
                                       object_id: user.id,
                                       display_name: user.full_name,
                                       reason: reason,
                                       data:)
        destroy_user!
      end
    end

  private

    attr_accessor :user, :reason

    def initialize(user, reason: "unvalidated/undeclared ECTS 2021 or 2022")
      @user = user
      @reason = reason
    end

    def user_can_be_archived?
      user.participant_profiles.npqs.none? &&
        ParticipantDeclaration.not_voided.where(participant_profile_id: user.participant_profiles.select(:id)).none? &&
          ECFParticipantEligibility.where(participant_profile_id: user.participant_profiles.select(:id)).none?
    end

    def destroy_user!
    end
  end
end
