# frozen_string_literal: true

module Admin
  module Archive
    class Table < BaseComponent
      include Pagy::Backend

      def initialize(relics:, page:)
        @pagy, @relics = pagy(relics, page:, items: 10)
      end

    private

      attr_reader :relics
    end
  end
end
