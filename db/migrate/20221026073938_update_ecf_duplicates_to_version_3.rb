# frozen_string_literal: true

class UpdateECFDuplicatesToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :ecf_duplicates, version: 3, revert_to_version: 2
  end
end
