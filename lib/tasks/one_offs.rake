# frozen_string_literal: true

namespace :one_offs do
  desc "Extend ECF Standard April started milestone date"
  task extend_ecf_standard_april_started_milestone_date: :environment do
    schedule = Finance::Schedule.find_by(name: "ECF Standard April")
    schedule.schedule_milestones.find_by(name: "Output 1.1 - Participant Start").destroy!
    Finance::Milestone.find_by(name: "Output 1.1 - Participant Start").destroy!
    schedule.milestones.find_by(declaration_type: "started").update!(milestone_date: Date.new(2022, 5, 31))
  end
end
