class AddRevisedTargetToCallOffContract < ActiveRecord::Migration[6.1]
  def change
    column_add :call_off_contract, :revised_target, :integer, default: null
  end
end
