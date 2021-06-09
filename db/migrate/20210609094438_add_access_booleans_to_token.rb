# frozen_string_literal: true

class AddAccessBooleansToToken < ActiveRecord::Migration[6.1]
  def change
    change_table :api_tokens, bulk: true do |t|
      t.boolean :private_api_access, default: false
    end
  end
end
