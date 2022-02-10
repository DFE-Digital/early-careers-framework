# frozen_string_literal: true

RSpec.describe Induction::Withdraw do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
    let!(:induction_record) { create(:induction_record, induction_programme: induction_programme, participant_profile: participant_profile, status: :active) }

    subject(:service) { described_class }

    it "updates the induction record with the given status" do
      service.call(participant_profile: participant_profile, induction_programme: induction_programme, state: :withdrawn, end_date: 2.days.from_now)
      expect(induction_record.reload).to be_withdrawn
    end

    context "when the programme does not contain an active record for the participant" do
      before do
        induction_record.completed!
      end

      it "does not update the induction record" do
        service.call(participant_profile: participant_profile,
                     induction_programme: induction_programme,
                     state: :withdrawn,
                     end_date: 2.days.from_now)
        expect(induction_record.reload).to be_completed
      end
    end
  end
end
