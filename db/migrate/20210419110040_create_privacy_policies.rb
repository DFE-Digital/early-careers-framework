# frozen_string_literal: true

class CreatePrivacyPolicies < ActiveRecord::Migration[6.1]
  class PrivacyPolicy < ApplicationRecord
  end

  def change
    create_table :privacy_policies, id: :uuid do |t|
      t.integer :major_version, null: false
      t.integer :minor_version, null: false

      t.text :html, null: false

      t.index %i[major_version minor_version], unique: true

      t.timestamps
    end
  end
end
