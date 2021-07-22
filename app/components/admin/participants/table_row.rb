# frozen_string_literal: true

module Admin
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :profile

      def initialize(profile:)
        @profile = profile
      end

    private

      attr_reader :profile
      delegate :school, to: :profile
    end
  end
end
