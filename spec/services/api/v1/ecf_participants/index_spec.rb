# frozen_string_literal: true

RSpec.describe Api::V1::ECFParticipants::Index, :with_default_schedules do
  let(:cpd_lead_provider) { induction_record.induction_programme.partnership.lead_provider.cpd_lead_provider }
  let(:induction_record) { participant_profile.induction_records[0] }
  let(:params) { {} }
  let(:participant_profile) { create(:ect) }
  let(:schedule) { create(:ecf_schedule) }
  let(:mentor_profile) { create(:mentor) }

  subject do
    described_class.new(cpd_lead_provider:, params:)
  end

  describe "#induction_records" do
    context "when a profile has multiple induction records eg. via change schedule" do
      before do
        Induction::ChangeMentor.call(
          induction_record:,
          mentor_profile:,
        )

        # this is to mimic iffy production data we have
        InductionRecord.update_all(start_date: 10.seconds.ago)
      end

      it "takes the latest one by created_at" do
        expect(subject.induction_records[0].mentor).to eql(mentor_profile.user)
      end
    end
  end
end
