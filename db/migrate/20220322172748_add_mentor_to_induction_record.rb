# frozen_string_literal: true

class AddMentorToInductionRecord < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :induction_records, :mentor_profile, null: true, index: { algorithm: :concurrently }
  end
end
