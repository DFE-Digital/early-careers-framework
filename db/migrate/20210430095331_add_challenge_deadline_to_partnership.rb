# frozen_string_literal: true

class AddChallengeDeadlineToPartnership < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :challenge_deadline, :datetime
  end
end
