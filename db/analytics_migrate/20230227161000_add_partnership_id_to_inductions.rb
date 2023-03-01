# frozen_string_literal: true

class AddPartnershipIdToInductions < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_inductions, :partnership_id, :uuid
  end
end
