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

  desc "Set NPQ Contract NPQEL target for LLSE to 84 for March 2022 - CPDLP-1148"
  task set_npq_contract_for_llse: :environment do
    npq_lead_provider = NPQLeadProvider.where(name: "Leadership Learning South East").first!
    cpd_lead_provider = npq_lead_provider.cpd_lead_provider
    march_statement = Finance::Statement.where(cpd_lead_provider_id: cpd_lead_provider.id, name: "March 2022").first!
    cohort = Cohort.where(start_year: 2021).first!
    new_contract_version = "0.0.2"

    # Change back to previous value
    contract = NPQContract.where(
      version: "0.0.1",
      npq_lead_provider_id: npq_lead_provider.id,
      cohort: cohort,
      course_identifier: "npq-executive-leadership",
    ).first!
    contract.update!(recruitment_target: 168)

    # Create version 0.0.2 contracts for NPQ Lead Provider with new target value for NPQEL
    contract_params = [
      {
        "recruitment_target" => 60,
        "course_identifier" => "npq-additional-support-offer",
        "service_fee_installments" => 24,
        "service_fee_percentage" => 0,
        "per_participant" => 800.0,
        "number_of_payment_periods" => 4,
        "output_payment_percentage" => 100,
      },
      {
        "recruitment_target" => 591,
        "course_identifier" => "npq-senior-leadership",
        "service_fee_installments" => 24,
        "service_fee_percentage" => 40,
        "per_participant" => 1080.0,
        "number_of_payment_periods" => 4,
        "output_payment_percentage" => 60,
      },
      {
        "recruitment_target" => 272,
        "course_identifier" => "npq-headship",
        "service_fee_installments" => 30,
        "service_fee_percentage" => 40,
        "per_participant" => 1975.0,
        "number_of_payment_periods" => 4,
        "output_payment_percentage" => 60,
      },
      {
        "recruitment_target" => 535,
        "course_identifier" => "npq-leading-teaching",
        "service_fee_installments" => 18,
        "service_fee_percentage" => 40,
        "per_participant" => 850.0,
        "number_of_payment_periods" => 3,
        "output_payment_percentage" => 60,
      },
      {
        "recruitment_target" => 84, ### This is the target for March 2022
        "course_identifier" => "npq-executive-leadership",
        "service_fee_installments" => 24,
        "service_fee_percentage" => 40,
        "per_participant" => 3900.0,
        "number_of_payment_periods" => 4,
        "output_payment_percentage" => 60,
      },
      {
        "recruitment_target" => 398,
        "course_identifier" => "npq-leading-teaching-development",
        "service_fee_installments" => 18,
        "service_fee_percentage" => 40,
        "per_participant" => 895.0,
        "number_of_payment_periods" => 3,
        "output_payment_percentage" => 60,
      },
      {
        "recruitment_target" => 393,
        "course_identifier" => "npq-leading-behaviour-culture",
        "service_fee_installments" => 18,
        "service_fee_percentage" => 40,
        "per_participant" => 895.0,
        "number_of_payment_periods" => 3,
        "output_payment_percentage" => 60,
      },
    ]

    contract_params.each do |params|
      contract = NPQContract.find_or_initialize_by(
        version: new_contract_version,
        npq_lead_provider_id: npq_lead_provider.id,
        cohort: cohort,
        course_identifier: params["course_identifier"],
      )
      contract.attributes = params
      contract.save!
    end

    march_statement.update!(contract_version: new_contract_version)
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
