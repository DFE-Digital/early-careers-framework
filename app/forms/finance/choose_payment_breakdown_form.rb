# frozen_string_literal: true

module Finance
  class ChoosePaymentBreakdownForm
    include ActiveModel::Model

    attr_accessor :programme, :provider

    validates :programme, presence: { message: "Please select programme type" }, on: :choose_programme
    validates :provider, presence: { message: "Please select a provider" }, on: :choose_provider

    def programme_choices
      [
        OpenStruct.new(id: "ecf", name: "ECF payments"),
        OpenStruct.new(id: "npq", name: "NPQ payments"),
      ]
    end

    def npq_providers
      NPQLeadProvider.all
    end

    def ecf_providers
      LeadProvider.all
    end
  end
end
