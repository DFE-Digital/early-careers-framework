# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECF::InductionRecordsQuery, :with_default_schedules do
  let(:cip_induction_programme) { create(:induction_programme, :cip) }

  let!(:induction_records_ect_1) { create(:induction_record, :ect, :preferred_identity) }
  let!(:induction_records_ect_2) { create(:induction_record, :ect, :preferred_identity) }
  let!(:induction_records_cip_ect) { create(:induction_record, :ect, :preferred_identity, induction_programme: cip_induction_programme) }
  let!(:induction_records_mentor) { create_list(:induction_record, 2, :mentor, :preferred_identity) }

  let!(:transferring_in_induction_record) do
    induction_record = create(:induction_record, :ect, :preferred_identity, start_date: 2.months.ago)
    induction_record.leaving!(1.month.from_now, transferring_out: false)
    induction_record
  end
  let!(:transferring_out_induction_record) do
    induction_record = create(:induction_record, :ect, :preferred_identity, start_date: 3.months.ago)
    induction_record.leaving!(2.months.ago, transferring_out: true)
    induction_record
  end
  let!(:withdrawn_induction_record) do
    induction_record = create(:induction_record, :ect, :preferred_identity, start_date: 2.weeks.ago)
    induction_record.withdrawing!(1.week.ago)
    induction_record
  end
  let!(:future_induction_record) { create(:induction_record, :ect, :preferred_identity, start_date: 1.year.from_now) }

  let(:induction_records_ects) do
    [
      induction_records_ect_1,
      induction_records_ect_2,
      induction_records_cip_ect,
      transferring_in_induction_record,
      transferring_out_induction_record,
      withdrawn_induction_record,
    ]
  end

  # real case from seed data
  let!(:non_ecf_induction_record) do
    induction_record = create(:induction_record)
    induction_record.participant_profile.update! type: "ParticipantProfile::NPQ"
    induction_record
  end

  let(:all_ecf_induction_records) { induction_records_ects + induction_records_mentor }
  let(:all_non_ecf_induction_records) { [non_ecf_induction_record] }

  subject { described_class.new.all }

  it "returns a list of induction records" do
    expect(subject).to all(be_a(InductionRecord))
  end

  it "includes ECF participants" do
    expect(subject).to include(*all_ecf_induction_records)
  end

  it "includes Mentor participants" do
    expect(subject).to include(*induction_records_mentor)
  end

  it "includes ECT participants" do
    expect(subject).to include(*induction_records_ects)
  end

  it "includes CIP participants" do
    expect(subject).to include(*induction_records_cip_ect)
  end

  it "includes past 'transferring_in' participants" do
    expect(subject).to include(transferring_in_induction_record)
  end

  it "includes past 'transferring_out' participants" do
    expect(subject).to include(transferring_out_induction_record)
  end

  it "includes past 'Withdrawn' participants" do
    expect(subject).to include(withdrawn_induction_record)
  end

  it "does not include Non-ECF participants" do
    expect(subject).not_to include(*all_non_ecf_induction_records)
  end

  it "does not include Future participants" do
    expect(subject).not_to include(future_induction_record)
  end

  context "when filtering by updated_since" do
    before { induction_records_ect_1.update(updated_at: 1.year.ago) }

    subject { described_class.new(updated_since: 4.months.ago).all }

    it "returns a list of users with updated_at timestamps later than the supplied one" do
      expect(subject).to match_array(all_ecf_induction_records.without(induction_records_ect_1))
    end
  end

  context "when filtering by email" do
    subject { described_class.new(email: induction_records_ect_1.preferred_identity.email).all }

    it "it only returns users with the matching email address" do
      expect(subject).to include(induction_records_ect_1)
      expect(subject).not_to include(all_ecf_induction_records.without(induction_records_ect_1))
    end
  end
end
