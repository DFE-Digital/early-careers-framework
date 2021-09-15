class AddRevisedTargetToCallOffContract < ActiveRecord::Migration[6.1]
  def change
    add_column :call_off_contracts, :revised_target, :integer, default: nil
  end
end
