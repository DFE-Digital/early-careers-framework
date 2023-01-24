# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPayable, :with_default_schedules do
  let(:cpd_lead_provider)                { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:cutoff_date)                      { Time.zone.local(2021, 11, 1) }
  let(:before_cutoff_date)               { cutoff_date - 1.day }
  let(:after_cutoff_date)                { cutoff_date + 1.day }
  let(:eligible_before_start_date_count) { 3 }
  let(:submitted_after_end_date_count)   { 2 }
  let(:ecf_declaration) do
    travel_to before_cutoff_date do
      create(:ect_participant_declaration, :eligible, declaration_date: before_cutoff_date, cpd_lead_provider:)
    end
  end
  let(:npq_declaration) do
    travel_to before_cutoff_date do
      %w[npq-specialist-spring npq-specialist-autumn].each do |schedule_identifier|
        create(:npq_specialist_schedule, schedule_identifier:, cohort: Cohort.current || create(:cohort, :current))
      end
      %w[npq-leadership-spring npq-leadership-autumn].each do |schedule_identifier|
        create(:npq_leadership_schedule, schedule_identifier:, cohort: Cohort.current || create(:cohort, :current))
      end
      create(:npq_participant_declaration, :eligible, declaration_date: before_cutoff_date, cpd_lead_provider:)
    end
  end

  before do
    create(:ecf_statement, :output_fee, cpd_lead_provider:, deadline_date: cutoff_date)
    create(:npq_statement, :output_fee, cpd_lead_provider:, deadline_date: cutoff_date)

    ecf_declaration
    npq_declaration

    travel_to after_cutoff_date do
      create_list(:ect_participant_declaration, submitted_after_end_date_count, :submitted, declaration_date: after_cutoff_date, cpd_lead_provider:)
      create_list(:npq_participant_declaration, submitted_after_end_date_count, :submitted, declaration_date: after_cutoff_date, cpd_lead_provider:)
    end
  end

  describe "#call" do
    context "with a ParticipantDeclaration::ECF type" do
      it "updates the declaration state", :aggregate_failures do
        expect(ecf_declaration).to be_eligible
        expect(ecf_declaration).not_to be_payable

        expect {
          described_class.call(declaration_class: ParticipantDeclaration::ECF, cutoff_date: cutoff_date.to_formatted_s(:db))
        }.to change(ParticipantDeclaration.payable, :count).from(0).to(1)

        expect(ecf_declaration.reload).not_to be_eligible
        expect(ecf_declaration).to be_payable
      end
    end

    context "with a ParticipantDeclaration::NPQ type" do
      it "updates the declaration state", :aggregate_failures do
        expect(npq_declaration).to be_eligible
        expect(npq_declaration).not_to be_payable

        expect {
          described_class.call(declaration_class: ParticipantDeclaration::NPQ, cutoff_date: cutoff_date.to_formatted_s(:db))
        }.to change(ParticipantDeclaration.payable, :count).from(0).to(1)

        expect(npq_declaration.reload).not_to be_eligible
        expect(npq_declaration).to be_payable
      end
    end
  end
end
