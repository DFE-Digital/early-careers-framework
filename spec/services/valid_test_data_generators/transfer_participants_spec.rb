# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::TransferParticipants do
  let(:cohort) { create(:cohort, :current) }
  let(:lead_provider) { create(:lead_provider) }
  let!(:participant_profile) { create(:ect, cohort:, lead_provider:) }

  let(:instance) { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    let(:number) { 1 }
    subject(:generate) { instance.call(number:) }

    context "when a participant profile can't be found" do
      let(:participant_profile) {}

      it { expect { generate }.not_to change(InductionRecord, :count) }
    end

    context "when transferring out" do
      before { allow(Faker::Boolean).to receive(:boolean).and_return(true) }

      it "sets the latest induction record to leaving/school transfer" do
        latest_induction_record = participant_profile.latest_induction_record

        expect { generate }.to change { latest_induction_record.reload.induction_status }.from("active").to("leaving")
          .and change { latest_induction_record.reload.school_transfer }.from(false).to(true)
      end
    end

    context "when transferring in (different school, same lead provider)" do
      let!(:other_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider:) }

      before { allow(Faker::Boolean).to receive(:boolean).and_return(false, true) }

      it "sets the latest induction record to leaving" do
        latest_induction_record = participant_profile.latest_induction_record

        expect { generate }.to change { latest_induction_record.reload.induction_status }.from("active").to("leaving")
      end

      it "creates a new, active/school transfer induction record for a different school and same lead provider" do
        expect { generate }.to change { participant_profile.induction_records.count }.from(1).to(2)

        new_induction_record = participant_profile.latest_induction_record

        expect(new_induction_record).to have_attributes(
          induction_status: "active",
          school_transfer: true,
          school_cohort: other_school_cohort,
          lead_provider:,
        )
      end

      context "when a different school can't be found" do
        let!(:other_school_cohort) {}

        it { expect { generate }.not_to change { participant_profile.latest_induction_record.reload.attributes } }
      end
    end

    context "when transferring in (different school, different lead provider)" do
      let!(:other_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: other_lead_provider) }
      let!(:other_lead_provider) { create(:lead_provider) }

      before { allow(Faker::Boolean).to receive(:boolean).and_return(false, false) }

      it "sets the latest induction record to leaving" do
        latest_induction_record = participant_profile.latest_induction_record

        expect { generate }.to change { latest_induction_record.reload.induction_status }.from("active").to("leaving")
      end

      it "creates a new, active/school transfer induction record for a different school and different lead provider" do
        expect { generate }.to change { participant_profile.induction_records.count }.from(1).to(2)

        new_induction_record = participant_profile.latest_induction_record

        expect(new_induction_record).to have_attributes(
          induction_status: "active",
          school_transfer: true,
          school_cohort: other_school_cohort,
          lead_provider: other_lead_provider,
        )
      end

      context "when a different school/lead provider can't be found" do
        let!(:other_school_cohort) {}

        it { expect { generate }.not_to change { participant_profile.latest_induction_record.reload.attributes } }
      end
    end
  end
end
