# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECF::InductionRecordsQuery, :with_support_for_ect_examples do
  subject { described_class.new.all }

  it "finds that latest and current return different results" do
    profile = cip_ect_only

    expect(profile.induction_records.count).to eq 1
    expect(profile.induction_records.current.first).to eq profile.induction_records.first
    expect(profile.induction_records.latest).to eq profile.induction_records.first
    expect(profile.induction_records.filter { |ir| ir.end_date.nil? }.count).to eq 1
    expect(profile.induction_records.filter { |ir| ir.end_date.nil? }.first).to eq profile.induction_records.first
  end

  it "returns a list of users" do
    included_records = records_for(
      cip_ect_only,
      cip_ect_reg_complete,
      fip_ect_only,
      fip_mentor_only,
      cip_mentor_only,
      cip_ect_updated_a_year_ago,
    )

    expect(subject).to all(be_a(InductionRecord))
    expect(subject).to match_array included_records
  end

  it "includes ECF participants" do
    included_records = records_for(
      cip_ect_only,
      cip_ect_reg_complete,
      fip_ect_only,
      fip_mentor_only,
      cip_mentor_only,
    )

    expect(subject).to match_array included_records
  end

  it "includes Mentor participants" do
    included_records = records_for(
      fip_mentor_only,
      cip_mentor_only,
    )

    expect(subject).to match_array included_records
  end

  it "includes ECT participants" do
    included_records = records_for(
      cip_ect_only,
      cip_ect_reg_complete,
      fip_ect_only,
    )

    expect(subject).to match_array included_records
  end

  it "includes CIP participants" do
    included_records = records_for(
      cip_ect_only,
      cip_ect_reg_complete,
      cip_mentor_only,
    )

    expect(subject).to match_array included_records
  end

  it "includes past 'transferring_in' participants" do
    included_records = records_for(
      fip_ect_transferring_in,
    )

    expect(subject).to match_array included_records
  end

  it "includes past 'transferring_out' participants" do
    included_records = records_for(
      fip_ect_transferring_out,
    )

    # current does not work for these sorts of records
    excluded_records = [
      fip_ect_transferring_out.induction_records.current.first,
    ]

    expect(subject).to match_array included_records
    expect(subject).not_to include(*excluded_records)
  end

  it "includes past 'Withdrawn' participants" do
    included_records = records_for(
      fip_ect_withdrawn,
    )

    # InductionRecord.current does not work for these sorts of records
    excluded_records = [
      fip_ect_withdrawn.induction_records.current.first,
    ]

    expect(subject).to match_array included_records
    expect(subject).not_to include(*excluded_records)
  end

  it "does not include Non-ECF participants" do
    excluded_records = records_for(
      npq_only,
      npq_with_induction_record,
    )

    expect(subject).not_to include(*excluded_records)
  end

  it "does not include Non-participant users" do
    excluded_records = records_for(
      sit_only,
    )

    expect(subject).not_to include(*excluded_records)
  end

  it "includes Future participants" do
    included_records = records_for(
      cip_ect_reg_for_future,
    )

    expect(subject).to match_array included_records
  end

  context "when filtering by updated_since" do
    let(:target) { cip_ect_updated_a_year_ago }

    subject { described_class.new(updated_since: target.updated_at + 1.month).all }

    it "returns a list of users with updated_at timestamps later than the supplied one" do
      included_records = records_for(
        cip_ect_only,
        cip_ect_reg_complete,
        fip_ect_only,
        fip_mentor_only,
        cip_mentor_only,
      )

      excluded_records = records_for(
        target,
      )

      expect(subject).to match_array included_records
      expect(subject).not_to include(*excluded_records)
    end
  end

  context "when filtering by email" do
    let(:target) { cip_ect_only }

    subject { described_class.new(email: target.user.email).all }

    it "it only returns users with the matching email address" do
      included_records = records_for(
        target,
      )

      excluded_records = records_for(
        cip_ect_reg_complete,
        fip_ect_only,
        fip_mentor_only,
        cip_mentor_only,
      )

      expect(subject).to match_array included_records
      expect(subject).not_to include(*excluded_records)
    end
  end

  context "complex scenarios" do
    it "excludes user withdrawn before we added induction_records once" do
      excluded_records = records_for(
        ect_with_no_induction_record,
      )

      # not found by query but is ignored by Support ECTs
      expect(subject).not_to include(*excluded_records)
    end

    it "includes user who is a second year ECT and is now a Mentor only as an ECT" do
      included_records = records_for(
        fip_ect_then_mentor[:ect_profile],
      )

      excluded_records = records_for(
        fip_ect_then_mentor[:mentor_profile],
      )

      # both have the same user so only the ECT record is returned
      expect(subject).to match_array included_records
      expect(subject).not_to include(*excluded_records)
    end

    it "includes user with a corrupt induction record history" do
      included_records = [
        cip_ect_with_corrupt_history.induction_records.filter { |ir| ir.end_date.nil? }.first,
      ]

      # InductionRecord.current and InductionRecord.latest do not work for these sorts of records
      excluded_records = [
        cip_ect_with_corrupt_history.induction_records.latest,
        cip_ect_with_corrupt_history.induction_records.current.first,
      ]

      expect(subject).to match_array included_records
      expect(subject).not_to include(*excluded_records)
    end

    it "includes a FIP ECT with no identity" do
      included_records = records_for(
        fip_ect_with_no_identity,
      )

      expect(subject).to match_array included_records
    end

    it "includes a FIP ECT with a different identity for some induction records once only" do
      included_records = [
        fip_ect_with_different_identity[:correct_profile].induction_records.filter { |ir| ir.end_date.nil? }.first,
        # InductionRecord.latest works here as it is the only induction_record for this profile
        fip_ect_with_different_identity[:wrong_profile].induction_records.latest,
      ]

      excluded_records = [
        # InductionRecord.latest does not work here as created_at order is mixed up
        fip_ect_with_different_identity[:correct_profile].induction_records.latest,
        # InductionRecord.current does not work here as it is withdrawn
        fip_ect_with_different_identity[:wrong_profile].induction_records.current.first,
      ]

      expect(subject).to match_array included_records
      expect(subject).not_to include(*excluded_records)
    end
  end

private

  def records_for(*profiles)
    profiles.map do |profile|
      profile.induction_records&.latest if profile.methods.include? :induction_records
    end
  end
end
