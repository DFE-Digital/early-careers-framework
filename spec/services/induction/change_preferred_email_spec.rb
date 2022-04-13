# frozen_string_literal: true

RSpec.describe Induction::ChangePreferredEmail do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme: induction_programme, participant_profile: participant_profile, start_date: 6.months.ago) }
    let!(:new_email) { "example.id2@example.com" }

    subject(:service) { described_class }

    it "adds a new induction record for the participant" do
      expect {
        service.call(induction_record: induction_record,
                     preferred_email: new_email)
      }.to change { induction_programme.induction_records.count }.by 1
    end

    describe "induction records" do
      before do
        service.call(induction_record: induction_record,
                     preferred_email: new_email)
      end

      it "updates the current induction record with status :changed" do
        expect(induction_record.reload).to be_changed_induction_status
      end

      it "sets the end_date to the current date" do
        expect(induction_record.reload.end_date).to be_within(1.second).of Time.zone.now
      end

      it "sets the new induction record data correctly" do
        new_induction_record = induction_programme.active_induction_records.first

        expect(new_induction_record).to be_active_induction_status
        expect(new_induction_record.start_date).to be_within(1.second).of Time.zone.now
        expect(new_induction_record.participant_profile).to eq participant_profile
        expect(new_induction_record.preferred_identity.email).to eq new_email
      end
    end
  end
end
