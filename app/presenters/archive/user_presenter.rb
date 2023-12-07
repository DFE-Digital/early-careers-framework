# frozen_string_literal: true

module Archive
  class UserPresenter < RelicPresenter
    def created_at
      Time.zone.parse(attribute(:created_at))
    end

    def participant_identities
      @participant_identities ||= ParticipantIdentityPresenter.wrap(attribute("participant_identities"))
    end

    def participant_profiles
      @participant_profiles ||= ParticipantProfilePresenter.wrap(attribute("participant_profiles"))
    end
  end
end
