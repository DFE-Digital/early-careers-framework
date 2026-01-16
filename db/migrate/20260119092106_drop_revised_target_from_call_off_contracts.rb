# frozen_string_literal: true

class DropRevisedTargetFromCallOffContracts < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :call_off_contracts, :revised_target, :integer }
  end
end
