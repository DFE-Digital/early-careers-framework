# frozen_string_literal: true

module Archive
  class ParticipantIdentityPresenter < RelicPresenter
    def email
      @email ||= attribute("email")
    end
  end
end
