# frozen_string_literal: true

class UpdateECFDuplicatesToVersion4 < ActiveRecord::Migration[6.1]
  def change
    update_view :ecf_duplicates, version: 4, revert_to_version: 3
  end
end
