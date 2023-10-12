# frozen_string_literal: true

module Admin
  module Archive
    class TableRow < BaseComponent
      with_collection_parameter :relic

      def initialize(relic:)
        @relic = relic
      end

      def email
        relic.data.dig("meta", "email")
      end

      def full_name
        relic.data.dig("meta", "full_name")
      end

      def created_date
        presenter.created_at.to_fs(:govuk)
      end

    private

      attr_reader :relic

      def presenter
        if relic.object_type == "User"
          ::Archive::UserPresenter.new(relic.data)
        else
          raise "Do not know how to present #{relic.object_type}"
        end
      end
    end
  end
end
