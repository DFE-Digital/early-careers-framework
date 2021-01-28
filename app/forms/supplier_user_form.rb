# frozen_string_literal: true

class SupplierUserForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :full_name, :email, :supplier
  validates :supplier, presence: { message: "Select one" }, on: :supplier
  validates :full_name, presence: { message: "Enter a name" }, on: :details
  validates :email, presence: { message: "Enter email" }, on: :details

  def attributes
    { "full_name" => nil, "email" => nil, "supplier" => nil }
  end

  def chosen_supplier
    LeadProvider.find_by(id: supplier) || DeliveryPartner.find_by(id: supplier)
  end
end
