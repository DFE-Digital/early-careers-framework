# frozen_string_literal: true

class CreateECFDuplicates < ActiveRecord::Migration[6.1]
  def change
    create_view :ecf_duplicates
  end
end
