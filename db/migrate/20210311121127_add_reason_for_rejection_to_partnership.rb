# frozen_string_literal: true

class AddReasonForRejectionToPartnership < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :reason_for_rejection, :string, null: true
  end
end
