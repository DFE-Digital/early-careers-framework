# frozen_string_literal: true

class UpdateECFDuplicatesToVersion5 < ActiveRecord::Migration[7.0]
  def change
    update_view :ecf_duplicates, version: 5, revert_to_version: 4
  end
end
