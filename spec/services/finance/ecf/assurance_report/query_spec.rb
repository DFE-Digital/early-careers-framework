# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ECF::AssuranceReport::Query, mid_cohort: true do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:statement) { create(:ecf_statement, cpd_lead_provider:) }

  let(:uplifts) { [] }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:participant_profile) { create(:ect, :eligible_for_funding, uplifts:, lead_provider: cpd_lead_provider.lead_provider) }
  let(:participant_identity) { participant_profile.participant_identity }
  let!(:participant_declaration) { travel_to(statement.deadline_date) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:, delivery_partner:) } }

  let(:other_statement) { create(:ecf_statement, cpd_lead_provider:, deadline_date: statement.deadline_date + 1.day) }
  let!(:other_participant_declaration) { travel_to(other_statement.deadline_date) { create(:ect_participant_declaration, cpd_lead_provider:) } }

  let(:other_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:other_cpd_lead_provider_statement) { create(:ecf_statement, cpd_lead_provider:, deadline_date: statement.deadline_date + 1.day) }
  let!(:other_cpd_lead_provider_participant_declaration) { travel_to(other_cpd_lead_provider_statement.deadline_date) { create(:ect_participant_declaration, cpd_lead_provider:) } }

  let(:query) { described_class.new(statement) }

  let(:assurance_report) { query.participant_declarations.first }
  let(:induction_record) { participant_profile.induction_records.latest }

  describe "#participant_declarations" do
    subject { query.participant_declarations }

    it { is_expected.to contain_exactly(participant_declaration) }
    it { expect(assurance_report.participant_id).to eq(participant_identity.user_id) }

    context "with multiple participant identities" do
      before do
        Induction::ChangePreferredEmail.call(induction_record:, preferred_email: "second_email@example.com")
        # We ideally should not update the existing participant identity on a profile when a new one is added
        # however, some of the data has this incorrect shape, so we should account for it.
        participant_profile.update!(participant_identity: ParticipantIdentity.find_by!(email: "second_email@example.com"))
      end

      it { is_expected.to contain_exactly(participant_declaration) }
      it { expect(assurance_report.participant_id).to eq(participant_identity.user_id) }
    end
  end

  describe "#delivery_partner_name" do
    subject { assurance_report.delivery_partner_name }

    it { is_expected.to eq(participant_declaration.delivery_partner.name) }
    it { is_expected.not_to eq(induction_record.delivery_partner.name) }

    context "when the declaration does not have a delivery partner" do
      let(:delivery_partner) { nil }

      it { is_expected.to eq(induction_record.delivery_partner.name) }
    end
  end

  describe "#sparsity_and_pp" do
    subject { assurance_report }

    context "with no uplifts" do
      it { is_expected.not_to be_sparsity_uplift }
      it { is_expected.not_to be_pupil_premium_uplift }
      it { is_expected.not_to be_sparsity_and_pp }
    end

    context "with sparsity_uplift" do
      let(:uplifts) { [:sparsity_uplift] }

      it { is_expected.to be_sparsity_uplift }
      it { is_expected.not_to be_pupil_premium_uplift }
      it { is_expected.not_to be_sparsity_and_pp }
    end

    context "with pupil_premium_uplift" do
      let(:uplifts) { [:pupil_premium_uplift] }

      it { is_expected.not_to be_sparsity_uplift }
      it { is_expected.to be_pupil_premium_uplift }
      it { is_expected.not_to be_sparsity_and_pp }
    end

    context "with sparsity_uplift and pupil_premium_uplift" do
      let(:uplifts) { %i[pupil_premium_and_sparsity_uplift] }

      it { is_expected.to be_sparsity_uplift }
      it { is_expected.to be_pupil_premium_uplift }
      it { is_expected.to be_sparsity_and_pp }
    end
  end
end
