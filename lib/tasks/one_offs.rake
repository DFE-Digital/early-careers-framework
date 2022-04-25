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

  desc "attach elibible declaration to next output statement"
  task attach_eligible_declaration_to_next_output_statement: :environment do
    CpdLeadProvider.find_each do |cpd_lead_provider|
      if (lead_provider = cpd_lead_provider.lead_provider)
        pp "ECF: #{cpd_lead_provider.lead_provider.name} -> #{lead_provider.next_output_fee_statement.name}"
        pp cpd_lead_provider.lead_provider.participant_declarations.eligible.where(statement_id: nil).count
        cpd_lead_provider.lead_provider.participant_declarations.eligible.where(statement_id: nil).update_all(statement_id: lead_provider.next_output_fee_statement.id)
      end
      if (npq_lead_provider = cpd_lead_provider.npq_lead_provider)
        pp "NPQ: #{cpd_lead_provider.npq_lead_provider.name} -> #{npq_lead_provider.next_output_fee_statement.name}"
        pp cpd_lead_provider.npq_lead_provider.participant_declarations.eligible.where(statement_id: nil).count
        npq_lead_provider
          .participant_declarations
          .eligible
          .where(statement_id: nil)
          .update_all(statement_id: npq_lead_provider.next_output_fee_statement.id)
      end
    end
  end
end
