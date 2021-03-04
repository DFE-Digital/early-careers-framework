# frozen_string_literal: true

class AddCohortsToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_reference :partnerships, :cohort, null: false, default: Cohort.find_or_create_by!(start_year: 2021).id, foreign_key: true
  end
end
