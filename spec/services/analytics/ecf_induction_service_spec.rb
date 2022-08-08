# frozen_string_literal: true

describe Analytics::ECFInductionService do
  let(:induction_programme) { create(:induction_programme, :fip) }
  let(:participant_profile) { create(:ecf_participant_profile, school_cohort: induction_programme.school_cohort) }
  let(:participant_identity) { participant_profile.participant_identity }
  let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile:, preferred_identity: participant_identity, start_date: Time.zone.now) }

  it "saves a new record" do
    expect {
      described_class.upsert_record(induction_record)
    }.to change { Analytics::ECFInduction.count }.by(1)
  end

  it "updates an existing record" do
    described_class.upsert_record(induction_record)

    expect(Analytics::ECFInduction.find_by(induction_record_id: induction_record.id)).to be_present

    end_date = 1.week.from_now
    induction_record.update_columns(induction_status: "leaving", end_date:)

    described_class.upsert_record(induction_record)

    record = Analytics::ECFInduction.find_by(induction_record_id: induction_record.id)
    expect(record.induction_status).to eq "leaving"
    expect(record.end_date).to be_within(1.second).of end_date
  end
end
