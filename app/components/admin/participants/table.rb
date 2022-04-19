# frozen_string_literal: true

module Admin
  module Participants
    class Table < BaseComponent
      include PaginationHelper
      include Pagy::Backend

      def initialize(profiles:, page:)
        @pagy, @profiles = pagy(profiles.includes(:user),
                                page: page,
                                items: 10)
      end

    private

      attr_reader :profiles
    end
  end
end
