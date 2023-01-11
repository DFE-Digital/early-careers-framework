# frozen_string_literal: true

module Admin::Participants
  class IdentitiesController < Admin::BaseController
    include RetrieveProfile

    def show
      @participant_identities = @participant_profile.user.participant_identities
    end
  end
end
