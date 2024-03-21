# frozen_string_literal: true

module Admin
  module ECF
    module Participants
      class Details < BaseComponent
        # An issue with this is that we have also a Admin::ParticipantPresenter, that should be merged with this component
        attr_reader :profile, :can_be_updated, :participant_presenter

        def initialize(profile:)
          @profile = profile
          @can_be_updated = can_be_updated
          @participant_presenter = participant_presenter
        end

        def show_edit_participant_link?
          profile.user.get_an_identity_id.present?
        end
      end
    end
  end
end
