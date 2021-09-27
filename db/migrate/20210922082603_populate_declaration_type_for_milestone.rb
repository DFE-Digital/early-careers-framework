# frozen_string_literal: true

class PopulateDeclarationTypeForMilestone < ActiveRecord::Migration[6.1]
  def up
    Finance::Schedule.all.each do |schedule|
      schedule.milestones[0]&.update!(declaration_type: "started")
      schedule.milestones[1]&.update!(declaration_type: "retained-1")
      schedule.milestones[2]&.update!(declaration_type: "retained-2")
      schedule.milestones[3]&.update!(declaration_type: "retained-3")
      schedule.milestones[4]&.update!(declaration_type: "retained-4")
      schedule.milestones[5]&.update!(declaration_type: "completed")
    end
  end
end
