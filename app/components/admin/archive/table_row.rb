# frozen_string_literal: true

module Admin
  module Archive
    class TableRow < BaseComponent
      with_collection_parameter :relic

      delegate :email, :full_name, to: :presenter

      def initialize(relic:)
        @relic = relic
      end

      def relic_type
        @relic.object_type
      end

      def created_date
        presenter.created_at.to_fs(:govuk)
      end

    private

      attr_reader :relic

      def presenter
        @presenter ||= ::Archive::RelicPresenter.presenter_for(relic["data"])
      end
    end
  end
end
