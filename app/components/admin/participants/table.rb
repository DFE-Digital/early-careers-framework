# frozen_string_literal: true

module Admin
  module Participants
    class Table < BaseComponent
      include PaginationHelper

      def initialize(profiles:, page:)
        @profiles = profiles.includes(:user).page(page).per(10)
      end

    private

      attr_reader :profiles
    end
  end
end
