# frozen_string_literal: true

require "csv"

# Creates a unique ECT participant profile and a ParticipantDeclaration::ECT
# linked to it. Returns the declaration.
def create_ecf_declaration(cpd_lead_provider:, cohort:, declaration_type:, state:, **extras)
  profile = FactoryBot.create(:ect_participant_profile, cohort:)
  ParticipantDeclaration::ECT.create!(
    cpd_lead_provider:,
    user: profile.user,
    participant_profile: profile,
    cohort:,
    course_identifier: "ecf-induction",
    declaration_type:,
    declaration_date: Date.new(2025, 1, 15),
    state:,
    **extras,
  )
end

# Creates a declaration with a "paid" line item on paid_out_statement AND an
# "awaiting_clawback" line item on clawback_statement.
def create_ecf_clawback_declaration(cpd_lead_provider:, cohort:, paid_out_statement:, clawback_statement:, declaration_type:, **extras)
  declaration = create_ecf_declaration(
    cpd_lead_provider:,
    cohort:,
    declaration_type:,
    state: :awaiting_clawback,
    **extras,
  )

  # Paid line item on the paid-out statement (billable bucket)
  Finance::StatementLineItem.create!(
    statement: paid_out_statement,
    participant_declaration: declaration,
    state: :paid,
  )

  # Awaiting clawback line item on the target statement (refundable bucket)
  Finance::StatementLineItem.create!(
    statement: clawback_statement,
    participant_declaration: declaration,
    state: :awaiting_clawback,
  )

  declaration
end

# Creates a billable declaration and its statement line item.
def create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement:, declaration_type:, state:, **extras)
  declaration = create_ecf_declaration(
    cpd_lead_provider:,
    cohort:,
    declaration_type:,
    state:,
    **extras,
  )

  Finance::StatementLineItem.create!(
    statement:,
    participant_declaration: declaration,
    state:,
  )

  declaration
end

namespace :payment_calculator do
  desc "Export Finance::ECF::StatementCalculator results as CSV for cross-system comparison with RECT"
  task verify: :environment do
    require "factory_bot_rails"

    ActiveRecord::Base.transaction do
      # ── 1. Seed Data ────────────────────────────────────────────────────

      cohort = FactoryBot.create(:cohort, :current)
      cpd_lead_provider = FactoryBot.create(:cpd_lead_provider, :with_lead_provider)
      lead_provider = cpd_lead_provider.lead_provider

      # Schedule (needed by participant profiles)
      FactoryBot.create(:ecf_schedule, cohort:)

      # CallOffContract with matching RECT params
      contract = CallOffContract.create!(
        lead_provider:,
        cohort:,
        version: "0.0.1",
        recruitment_target: 200,
        uplift_amount: 100,
        set_up_fee: 500,
        monthly_service_fee: nil,
      )

      # 3 Participant Bands: A, B, C — all 60/40 output/service (defaults)
      ParticipantBand.create!(call_off_contract: contract, min: nil, max: 100, per_participant: 800)
      ParticipantBand.create!(call_off_contract: contract, min: 101, max: 200, per_participant: 600)
      ParticipantBand.create!(call_off_contract: contract, min: 201, max: 300, per_participant: 400)

      # Statements
      paid_out_statement = Finance::Statement::ECF::Paid.create!(
        name: "January 2025",
        cpd_lead_provider:,
        cohort:,
        contract_version: "0.0.1",
        mentor_contract_version: "0.0.1",
        payment_date: Date.new(2025, 2, 1),
        deadline_date: Date.new(2025, 1, 31),
        output_fee: true,
        marked_as_paid_at: Time.zone.now,
      )

      previous_statement = Finance::Statement::ECF::Paid.create!(
        name: "May 2025",
        cpd_lead_provider:,
        cohort:,
        contract_version: "0.0.1",
        mentor_contract_version: "0.0.1",
        payment_date: Date.new(2025, 6, 1),
        deadline_date: Date.new(2025, 5, 31),
        output_fee: true,
        marked_as_paid_at: Time.zone.now,
      )

      current_statement = Finance::Statement::ECF::Payable.create!(
        name: "June 2025",
        cpd_lead_provider:,
        cohort:,
        contract_version: "0.0.1",
        mentor_contract_version: "0.0.1",
        payment_date: Date.new(2025, 7, 1),
        deadline_date: Date.new(2025, 6, 30),
        output_fee: true,
      )

      # ── Previous statement declarations ─────────────────────────────────

      # 10x started/eligible (billable)
      10.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: previous_statement, declaration_type: "started", state: :eligible) }

      # 5x retained-1/payable (billable)
      5.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: previous_statement, declaration_type: "retained-1", state: :payable) }

      # 2x started/awaiting_clawback (refundable) on previous statement
      2.times { create_ecf_clawback_declaration(cpd_lead_provider:, cohort:, paid_out_statement:, clawback_statement: previous_statement, declaration_type: "started") }

      # ── Current statement declarations ──────────────────────────────────

      # 5x started/eligible (billable)
      5.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: current_statement, declaration_type: "started", state: :eligible) }

      # 3x started/payable with sparsity uplift
      3.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: current_statement, declaration_type: "started", state: :payable, sparsity_uplift: true) }

      # 2x started/payable with pupil premium uplift
      2.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: current_statement, declaration_type: "started", state: :payable, pupil_premium_uplift: true) }

      # 3x retained-1/eligible (billable)
      3.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: current_statement, declaration_type: "retained-1", state: :eligible) }

      # 4x retained-2/payable (billable)
      4.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: current_statement, declaration_type: "retained-2", state: :payable) }

      # 2x completed/eligible (billable)
      2.times { create_ecf_billable_declaration(cpd_lead_provider:, cohort:, statement: current_statement, declaration_type: "completed", state: :eligible) }

      # 3x started/awaiting_clawback (refundable) on current statement
      3.times { create_ecf_clawback_declaration(cpd_lead_provider:, cohort:, paid_out_statement:, clawback_statement: current_statement, declaration_type: "started") }

      # 1x started/awaiting_clawback with sparsity uplift (refundable)
      create_ecf_clawback_declaration(cpd_lead_provider:, cohort:, paid_out_statement:, clawback_statement: current_statement, declaration_type: "started", sparsity_uplift: true)

      # 1x completed/awaiting_clawback (refundable) on current statement
      create_ecf_clawback_declaration(cpd_lead_provider:, cohort:, paid_out_statement:, clawback_statement: current_statement, declaration_type: "completed")

      # ── Adjustments on current statement ────────────────────────────────

      Finance::Adjustment.create!(statement: current_statement, payment_type: "Adjustment 1", amount: 150.00)
      Finance::Adjustment.create!(statement: current_statement, payment_type: "Adjustment 2", amount: -50.00)

      # ── 2. Run Calculator ───────────────────────────────────────────────

      calculator = Finance::ECF::StatementCalculator.new(statement: current_statement)
      output_calculator = calculator.send(:output_calculator)
      bands = calculator.bands

      # ── 3. Generate CSV ─────────────────────────────────────────────────

      declaration_types = %w[started retained-1 retained-2 retained-3 retained-4 completed extended-1 extended-2 extended-3]
      band_letters = (:a..:z).take(bands.size).to_a
      ecf_type = ->(type) { type.tr("-", "_") }

      csv_string = CSV.generate do |csv|
        csv << %w[section ecf_method rect_method value]

        # ── BandingCalculator per declaration_type per band ─────────────
        declaration_types.each do |declaration_type|
          type = ecf_type.call(declaration_type)
          banding_calc = output_calculator.banding_for(declaration_type:)
          banding_data = banding_calc.send(:banding)

          band_letters.each_with_index do |letter, i|
            band_data = banding_data[i] || {}

            csv << ["banding", "#{type}_previous_count_#{letter}", "band_allocation.previous_billable_count - previous_refundable_count", band_data[:previous_count] || 0]
            csv << ["banding", "#{type}_additions_#{letter}", "band_allocation.billable_count", banding_calc.additions(letter)]
            csv << ["banding", "#{type}_subtractions_#{letter}", "band_allocation.refundable_count", banding_calc.subtractions(letter)]
            csv << ["banding", "#{type}_count_#{letter}", "band_allocation.net_billable_count", banding_calc.count(letter)]
          end

          # ── StatementCalculator per declaration_type per band ───────────
          type = ecf_type.call(declaration_type)

          band_letters.each do |letter|
            fee = calculator.fee_for_declaration(band_letter: letter, type: type.to_sym)
            additions = calculator.send("#{type}_band_#{letter}_additions")
            subtractions = calculator.send("#{type}_band_#{letter}_subtractions")

            csv << ["statement", "#{type}_band_#{letter}_fee_per_declaration", "declaration_type_output.output_fee_per_declaration", sprintf("%.2f", fee)]
            csv << ["statement", "#{type}_band_#{letter}_additions", "declaration_type_output.band_allocation.billable_count", additions]
            csv << ["statement", "#{type}_band_#{letter}_subtractions", "declaration_type_output.band_allocation.refundable_count", subtractions]
          end

          # ── StatementCalculator per declaration_type totals ─────────────
          type = ecf_type.call(declaration_type)
          additions_total = calculator.send("additions_for_#{type}")
          deductions_total = calculator.send("deductions_for_#{type}")

          csv << ["statement", "additions_for_#{type}", "sum(declaration_type_output.total_billable_amount)", sprintf("%.2f", additions_total)]
          csv << ["statement", "deductions_for_#{type}", "sum(declaration_type_output.total_refundable_amount)", sprintf("%.2f", deductions_total)]
        end

        # ── StatementCalculator output totals ───────────────────────────
        csv << ["statement", "output_fee", "outputs.total_billable_amount", sprintf("%.2f", calculator.output_fee)]
        csv << ["statement", "clawback_deductions", "outputs.total_refundable_amount", sprintf("%.2f", calculator.clawback_deductions)]

        # ── StatementCalculator uplift ──────────────────────────────────
        csv << ["statement", "uplift_fee_per_declaration", "banded_fee_structure.uplift_fee_per_declaration", calculator.uplift_fee_per_declaration]
        csv << ["statement", "uplift_additions_count", "uplifts.billable_count", calculator.uplift_additions_count]
        csv << ["statement", "uplift_deductions_count", "uplifts.refundable_count", calculator.uplift_deductions_count]
        csv << ["statement", "uplift_count", "uplifts.net_count", calculator.uplift_count]
        csv << ["statement", "uplift_payment", "uplifts.total_billable_amount", sprintf("%.2f", calculator.uplift_payment)]
        csv << ["statement", "uplift_clawback_deductions", "-uplifts.total_refundable_amount", sprintf("%.2f", calculator.uplift_clawback_deductions)]
        csv << ["statement", "total_for_uplift", "uplifts.total_net_amount", sprintf("%.2f", calculator.total_for_uplift)]

        # ── StatementCalculator adjustments ─────────────────────────────
        csv << ["statement", "adjustments_total", "-(outputs.total_refundable_amount + uplifts.total_refundable_amount)", sprintf("%.2f", calculator.adjustments_total)]
        csv << ["statement", "additional_adjustments_total", "calculator.total_manual_adjustments_amount", sprintf("%.2f", calculator.additional_adjustments_total)]

        # ── StatementCalculator service fee ─────────────────────────────
        csv << ["statement", "service_fee", "calculator.monthly_service_fee", sprintf("%.2f", calculator.service_fee)]
        csv << ["statement", "calculated_service_fee", "service_fees.monthly_amount", sprintf("%.2f", calculator.send(:calculated_service_fee))]

        # ── StatementCalculator setup fee ─────────────────────────────
        csv << ["statement", "set_up_fee", "calculator.setup_fee", sprintf("%.2f", contract.set_up_fee)]

        # ── StatementCalculator totals ──────────────────────────────────
        csv << ["statement", "total", "calculator.total_amount(with_vat: false)", sprintf("%.2f", calculator.total)]
        vat = calculator.vat
        csv << ["statement", "vat", "total_amount(with_vat: true) - total_amount(with_vat: false)", sprintf("%.2f", vat)]
        csv << ["statement", "total_with_vat", "calculator.total_amount(with_vat: true)", sprintf("%.2f", calculator.total(with_vat: true))]
      end

      output_path = Rails.root.join("ecf_output.csv")
      File.write(output_path, csv_string)
      puts "Written to #{output_path}"

      raise ActiveRecord::Rollback
    end
  end
end
