# frozen_string_literal: true

describe Analytics::ECFSchoolCohortService do
  let(:school_cohort) { create(:school_cohort, :fip) }

  it "saves a new record" do
    expect {
      described_class.upsert_record(school_cohort)
    }.to change { Analytics::ECFSchoolCohort.count }.by(1)
  end

  it "updates an existing record" do
    described_class.upsert_record(school_cohort)

    analytics_record = Analytics::ECFSchoolCohort.find_by(school_cohort_id: school_cohort.id)
    expect(analytics_record).to be_present

    school_cohort.core_induction_programme!
    described_class.upsert_record(school_cohort)

    expect(analytics_record.reload.induction_programme_choice).to eq "core_induction_programme"
  end
end
