# frozen_string_literal: true

module Finance
  class ChoosePaymentBreakdownForm
    include ActiveModel::Model

    attr_accessor :programme, :provider

    validates :programme, presence: { message: I18n.t("errors.programme.blank") }, on: :choose_programme
    validates :provider, presence: { message: I18n.t("errors.provider.blank") }, on: :choose_provider

    def programme_choices
      choices = [OpenStruct.new(id: "ecf", name: "ECF payments")]

      unless FeatureFlag.active?(:disable_npq)
        choices << OpenStruct.new(id: "npq", name: "NPQ payments")
      end

      choices
    end

    def npq_providers
      NPQLeadProvider.name_order
    end

    def ecf_providers
      LeadProvider.name_order
    end
  end
end
