# frozen_string_literal: true

class AddSparsityPremiumToECFSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_schools, :pupil_premium, :boolean
    add_column :ecf_schools, :sparsity, :boolean
  end
end
