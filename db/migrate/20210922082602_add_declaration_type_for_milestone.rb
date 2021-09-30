# frozen_string_literal: true

class AddDeclarationTypeForMilestone < ActiveRecord::Migration[6.1]
  def change
    add_column :milestones, :declaration_type, :string
  end
end
