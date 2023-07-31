# frozen_string_literal: true

class ChangeECFPartnershipsChallengeDeadlinePrecision < ActiveRecord::Migration[7.0]
  def up
    safety_assured { change_column :ecf_partnerships, :challenge_deadline, :datetime, precision: nil }
  end

  def down
    safety_assured { change_column :ecf_partnerships, :challenge_deadline, :datetime }
  end
end
