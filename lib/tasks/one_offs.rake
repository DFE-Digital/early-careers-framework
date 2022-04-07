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
end
