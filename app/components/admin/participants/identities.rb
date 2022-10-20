# frozen_string_literal: true

module Admin
  module Participants
    class Identities < BaseComponent
      attr_reader :identities

      def initialize(identities:)
        @identities = identities
      end

      def identity_transferred_label(identity)
        if identity.user_id == identity.external_identifier
          "Original"
        else
          "Transferred"
        end
      end
    end
  end
end
