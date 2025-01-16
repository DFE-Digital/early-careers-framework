# frozen_string_literal: true

class DeleteNPQFinanceSchedules < ActiveRecord::Migration[7.1]
  def up
    schedule_types = [
      "Finance::Schedule::NPQ",
      "Finance::Schedule::NPQEhco",
      "Finance::Schedule::NPQSupport",
      "Finance::Schedule::NPQSpecialist",
      "Finance::Schedule::NPQLeadership",
    ]

    ParticipantProfileSchedule.includes(:schedule).where(schedule: { type: schedule_types }).in_batches(of: 10_000) { |batch| batch.delete_all }
    Finance::ScheduleMilestone.includes(:schedule).where(schedule: { type: schedule_types }).in_batches(of: 10_000) { |batch| batch.delete_all }
    Finance::Milestone.includes(:schedule).where(schedule: { type: schedule_types }).in_batches(of: 10_000) { |batch| batch.delete_all }
    Finance::Schedule.where(type: schedule_types).in_batches(of: 10_000) { |batch| batch.delete_all }
  end
end
