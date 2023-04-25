# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::BuildTransfers, :with_default_schedules do
  describe ".call" do
    let!(:cohort) { Cohort.current || create(:cohort, :current) }
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:leaving_partnership) { create(:partnership, lead_provider:, cohort:) }
    let(:leaving_school_cohort) { create(:school_cohort, cohort:) }
    let(:leaving_induction_programme) { create(:induction_programme, :fip, partnership: leaving_partnership, school_cohort: leaving_school_cohort) }
    let!(:leaving_induction_record) do
      create(:induction_record, :leaving, :preferred_identity, induction_programme: leaving_induction_programme, end_date:)
    end
    let(:participant_profile) { leaving_induction_record.participant_profile }
    let(:user) { participant_profile.user }
    let(:end_date) { Time.zone.now }

    subject { described_class.new(participant_profile:, cpd_lead_provider:) }

    context "when leaving SIT triggers a FIP transfer" do
      let(:expected_transfer) do
        [leaving_induction_record, nil]
      end

      it "sets the leaving induction_record" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end
    end

    context "when joining SIT triggers a FIP transfer with same lead provider" do
      let(:joining_partnership) { create(:partnership, lead_provider:, cohort:) }
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: end_date, participant_profile:)
      end
      let(:expected_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end
    end

    context "when joining SIT triggers a FIP transfer with different lead provider" do
      let(:joining_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:joining_lead_provider) { joining_cpd_lead_provider.lead_provider }
      let(:joining_partnership) { create(:partnership, lead_provider: joining_lead_provider, cohort:) }
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date:, participant_profile:)
      end
      let(:start_date) { 1.day.from_now }

      let(:expected_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end
    end

    context "with FIP to CIP school transfers" do
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :cip, school_cohort: joining_school_cohort) }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date:, participant_profile:)
      end
      let(:start_date) { 1.day.from_now }

      let(:expected_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end
    end

    context "with CIP to FIP school transfers" do
      let(:leaving_induction_programme) { create(:induction_programme, :cip, school_cohort: leaving_school_cohort) }
      let(:joining_partnership) { create(:partnership, lead_provider:, cohort:) }
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let(:start_date) { 1.day.from_now }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date:, participant_profile:)
      end

      let(:expected_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end
    end

    context "with multiple transfers" do
      let!(:leaving_induction_record) do
        create(:induction_record, :leaving, :preferred_identity, induction_programme: leaving_induction_programme, start_date: leaving_start_date, end_date: leaving_end_date)
      end
      let(:joining_partnership) { create(:partnership, lead_provider:, cohort:) }
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: joining_start_date, participant_profile:)
      end
      let(:latest_leaving_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:latest_leaving_induction_record) do
        create(:induction_record, :leaving, :preferred_identity, induction_programme: latest_leaving_induction_programme, start_date: latest_leaving_start_date, end_date: latest_leaving_end_date, participant_profile:)
      end
      let(:leaving_start_date) { 3.days.ago }
      let(:leaving_end_date) { 2.days.ago }
      let(:joining_start_date) { 1.day.ago }
      let(:latest_leaving_start_date) { Time.zone.now }
      let(:latest_leaving_end_date) { 1.day.from_now }

      it "surfaces all transfers" do
        expect(subject.call.size).to eq(2)
      end

      let(:expected_first_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      let(:expected_second_transfer) do
        [latest_leaving_induction_record, nil]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_first_transfer, expected_second_transfer)
      end
    end

    context "with multiple transfers and lead providers" do
      let!(:leaving_induction_record) do
        create(:induction_record, :leaving, :preferred_identity, induction_programme: leaving_induction_programme, start_date: leaving_start_date, end_date: leaving_end_date)
      end
      let(:joining_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:joining_lead_provider) { joining_cpd_lead_provider.lead_provider }
      let(:joining_partnership) { create(:partnership, lead_provider: joining_lead_provider, cohort:) }
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: joining_start_date, participant_profile:)
      end
      let(:latest_leaving_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:latest_leaving_induction_record) do
        create(:induction_record, :leaving, :preferred_identity, induction_programme: latest_leaving_induction_programme, start_date: latest_leaving_start_date, end_date: latest_leaving_end_date, participant_profile:)
      end

      let(:leaving_start_date) { 3.days.ago }
      let(:leaving_end_date) { 2.days.ago }
      let(:joining_start_date) { 1.day.ago }
      let(:latest_leaving_start_date) { Time.zone.now }
      let(:latest_leaving_end_date) { 1.day.from_now }

      let(:expected_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end

      context "when other lead provider gets transfers" do
        subject { described_class.new(participant_profile:, cpd_lead_provider: joining_cpd_lead_provider) }

        it "surfaces both transfers" do
          expect(subject.call.size).to eq(2)
        end
      end
    end

    context "with out of order induction records" do
      let!(:changing_induction_record) do
        create(:induction_record, :preferred_identity, induction_status: "changed", induction_programme: leaving_induction_programme, end_date: Time.zone.now)
      end
      let(:participant_profile) { changing_induction_record.participant_profile }
      let(:joining_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:joining_lead_provider) { joining_cpd_lead_provider.lead_provider }
      let(:joining_partnership) { create(:partnership, lead_provider: joining_lead_provider, cohort:) }
      let(:joining_school_cohort) { create(:school_cohort, cohort:) }
      let(:joining_induction_programme) { create(:induction_programme, :fip, partnership: joining_partnership, school_cohort: joining_school_cohort) }
      let!(:joining_induction_record) do
        create(:induction_record, :preferred_identity, induction_programme: joining_induction_programme, start_date: end_date, participant_profile:)
      end

      let!(:leaving_induction_record) do
        travel_to(joining_induction_record.created_at + 1.day) do
          create(:induction_record, :leaving, induction_programme: leaving_induction_programme, start_date: Time.zone.now, end_date:, participant_profile:)
        end
      end
      let(:end_date) { 1.day.ago }

      let(:expected_transfer) do
        [leaving_induction_record, joining_induction_record]
      end

      it "sets the leaving and joining induction_records" do
        expect(subject.call).to contain_exactly(expected_transfer)
      end

      context "when other lead provider gets transfers" do
        subject { described_class.new(cpd_lead_provider: joining_cpd_lead_provider, participant_profile:) }

        let(:expected_transfer) do
          [leaving_induction_record, joining_induction_record]
        end

        it "sets the leaving and joining induction_records" do
          expect(subject.call).to contain_exactly(expected_transfer)
        end
      end
    end
  end
end
