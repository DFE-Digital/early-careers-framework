# frozen_string_literal: true

class ChangeECFPartnershipsChallengedAtPrecision < ActiveRecord::Migration[7.0]
  def up
    safety_assured { change_column :ecf_partnerships, :challenged_at, :datetime, precision: nil }
  end

  def down
    safety_assured { change_column :ecf_partnerships, :challenged_at, :datetime }
  end
end
