# frozen_string_literal: true

module Admin
  module RecordsAnalysis
    class NPQApplicationTable < BaseComponent
      include Pagy::Backend

      def initialize(applications:, page:)
        @pagy, @applications = pagy(applications, page:, items: 10)
      end

    private

      attr_reader :applications
    end
  end
end
