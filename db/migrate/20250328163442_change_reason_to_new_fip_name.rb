# frozen_string_literal: true

class ChangeReasonToNewFipName < ActiveRecord::Migration[7.1]
  def change
    ParticipantProfileState.where(reason: "school-left-fip").update_all(reason: "school-left-provider-led")
  end
end
