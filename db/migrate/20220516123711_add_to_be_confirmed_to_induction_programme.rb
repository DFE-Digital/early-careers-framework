# frozen_string_literal: true

class AddToBeConfirmedToInductionProgramme < ActiveRecord::Migration[6.1]
  def change
    add_column :induction_programmes, "lead_provider_to_be_confirmed", :boolean, default: false
    add_column :induction_programmes, "delivery_partner_to_be_confirmed", :boolean, default: false
  end
end
