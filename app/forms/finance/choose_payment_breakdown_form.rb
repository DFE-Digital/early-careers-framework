# frozen_string_literal: true

module Finance
  class ChoosePaymentBreakdownForm
    include ActiveModel::Model

    attr_accessor :programme, :provider

    validates :programme, presence: { message: I18n.t("errors.programme.blank") }, on: :choose_programme
    validates :provider, presence: { message: I18n.t("errors.provider.blank") }, on: :choose_provider

    def ecf_providers
      LeadProvider.name_order
    end
  end
end
