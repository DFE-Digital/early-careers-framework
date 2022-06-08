# frozen_string_literal: true

class AddUpliftFlagsToDeclaration < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_declarations, :sparsity_uplift, :boolean, null: true
    add_column :participant_declarations, :pupil_premium_uplift, :boolean, null: true
  end
end
