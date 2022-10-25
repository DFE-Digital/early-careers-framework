# frozen_string_literal: true

module Admin
  module Participants
    class Identities < BaseComponent
      attr_reader :identities

      def initialize(identities:)
        @identities = identities
      end

      def identity_transferred_label(identity)
        if identity.original_identity?
          "Original"
        elsif identity.transferred_identity?
          "Transferred"
        elsif identity.additional_identity?
          "Additional"
        end
      end
    end
  end
end
