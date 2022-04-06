# frozen_string_literal: true

namespace :one_offs do
  desc "attach all statements to cohort 2021"
  task backfill_statement_cohort: :environment do
    Finance::Statement.update_all(cohort_id: Cohort.find_by(start_year: 2021).id)
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  desc "attach all contracts to cohort 2021"
  task backfill_contract_cohort: :environment do
    CallOffContract.update_all(cohort_id: Cohort.find_by(start_year: 2021).id)
    NPQContract.update_all(cohort_id: Cohort.find_by(start_year: 2021).id)
  rescue StandardError => e
    Sentry.capture_exception(e)
  end

  desc "populate schedule_milestone"
  task populate_schedule_milestones: :environment do
    Finance::Schedule.includes(:milestones).find_each do |schedule|
      schedule.milestones.each do |milestone|
        actual_milestone = Finance::Milestone.where(milestone.slice(:start_date, :payment_date, :milestone_date)).order(created_at: :asc).first
        schedule.schedule_milestones.create!(
          name: milestone.name,
          declaration_type: milestone.declaration_type,
          milestone: actual_milestone,
        )
      end
    end
  end

  desc "Resolve issues in ECF hard schedule reference data - CPDLP-1164"
  task resolve_issues_in_ecf_schedule_start_date: :environment do
    changes = {
      "ecf-standard-january" => {
        "Output 6 - Participant Completion" => "2023-05-01", # from: 1 February 2023
      },
      "ecf-standard-april" => {
        "Output 1 - Participant Start" => "2022-02-01", # from: 1 March 2022
        "Output 2 - Retention Point 1" => "2022-05-01", # from: 1 June 2022
        "Output 3 - Retention Point 2" => "2022-10-01", # from: 1 November 2022
        "Output 4 - Retention Point 3" => "2023-02-01", # from: 1 March 2023
        "Output 5 - Retention Point 4" => "2023-05-01", # from: 1 June 2023
        "Output 6 - Participant Completion" => "2023-11-01", # from: 1 December 2023
      },
    }

    changes.each do |schedule_identifier, milestone_changes|
      Finance::Schedule.where(schedule_identifier: schedule_identifier).find_each do |schedule|
        puts "Schedule: #{schedule_identifier}"
        milestone_changes.each do |name, start_date|
          milestone = schedule.milestones.where(name: name).first
          puts "Milestone change: #{milestone.start_date.iso8601} to #{start_date}"
          milestone.update!(start_date: start_date)
        end
      end
    end
  end
end
