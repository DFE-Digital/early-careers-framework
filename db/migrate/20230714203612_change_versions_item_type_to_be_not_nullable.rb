# frozen_string_literal: true

class ChangeVersionsItemTypeToBeNotNullable < ActiveRecord::Migration[7.0]
  def change
    safety_assured { change_column_null :versions, :item_type, false }
  end
end
