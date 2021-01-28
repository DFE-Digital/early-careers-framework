# frozen_string_literal: true

class SupplierUserForm
  include ActiveModel::Model

  attr_accessor :full_name, :supplier
  validates :supplier, presence: { message: "Select one" }, on: :supplier
end
