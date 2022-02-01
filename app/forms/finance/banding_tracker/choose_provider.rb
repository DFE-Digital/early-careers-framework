# frozen_string_literal: true

module Finance
  module BandingTracker
    class ChooseProvider
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :id

      validates :id, presence: { message: I18n.t("errors.provider.blank") }

      def provider
        @provider ||= LeadProvider.find(id)
      end
    end
  end
end
