# frozen_string_literal: true

class NewSupplierForm
  include ActiveModel::Model

  attr_accessor :name, :type

  def supplier_types
    [OpenStruct.new(id: "lead_provider", name: "Lead provider", hint: "A top level training provider who has been awarded a contract."),
     OpenStruct.new(id: "delivery_partner", name: "Delivery partner", hint: "A local teaching school or hub chosen by the lead provider.")]
  end
end
