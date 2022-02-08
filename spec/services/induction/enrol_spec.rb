# frozen_string_literal: true

RSpec.describe Induction::Enrol do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let!(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }

    subject(:service) { described_class }

    it "creates an induction record for the given programme" do
      expect { service.call(participant_profile: participant_profile, induction_programme: induction_programme) }.to change { InductionRecord.count }.by 1
    end

    context "when an induction programme is not specified" do
      before do
        school_cohort.update!(default_induction_programme: induction_programme)
      end

      it "uses the default induction programme for the school cohort" do
        expect { service.call(participant_profile: participant_profile) }.to change { InductionRecord.count }.by 1
        expect(participant_profile.induction_records.first.induction_programme).to eq(induction_programme)
      end
    end
  end
end
