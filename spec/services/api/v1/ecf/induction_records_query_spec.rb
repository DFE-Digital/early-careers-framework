# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECF::InductionRecordsQuery, :with_default_schedules do
  let!(:induction_records_ect_1) { create(:induction_record, :ect, :preferred_identity) }
  let!(:induction_records_ect_2) { create(:induction_record, :ect, :preferred_identity) }
  let!(:induction_records_mentor) { create_list(:induction_record, 2, :mentor, :preferred_identity) }
  let(:all_ecf_induction_records) { [induction_records_ect_1, induction_records_ect_2] + induction_records_mentor }
  let!(:non_ecf_induction_record) { create(:induction_record) }

  subject { described_class.new.all }

  it "returns a list of induction records" do
    expect(subject).to all(be_a(InductionRecord))
  end

  it "only includes ECF participants" do
    expect(subject).to match_array(all_ecf_induction_records)
    expect(subject).not_to include(non_ecf_induction_record)
  end

  context "when filtering by updated_since" do
    before { induction_records_ect_1.update(updated_at: 1.year.ago) }

    subject { described_class.new(updated_since: 1.month.ago).all }

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
