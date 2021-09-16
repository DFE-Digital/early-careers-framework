# frozen_string_literal: true

module Finance
  class ChooseProgrammeForm
    include ActiveModel::Model

    attr_accessor :choice, :provider

    def choices
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
