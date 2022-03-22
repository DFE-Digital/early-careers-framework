# frozen_string_literal: true

RSpec.describe Induction::ChangePreferredIdentity do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
    let!(:induction_record) { create(:induction_record, induction_programme: induction_programme, participant_profile: participant_profile, status: :active, start_date: 6.months.ago) }
    let!(:new_identity) { Identity::Create.call(user: participant_profile.participant_identity.user, email: "example.id2@example.com") }

    subject(:service) { described_class }

    it "adds a new induction record for the participant" do
      expect {
        service.call(induction_record: induction_record,
                     preferred_identity: new_identity)
      }.to change { induction_programme.induction_records.count }.by 1
    end

    describe "induction records" do
      before do
        service.call(induction_record: induction_record,
                     preferred_identity: new_identity)
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
        expect(new_induction_record.preferred_identity).to eq new_identity
      end
    end
  end
end
