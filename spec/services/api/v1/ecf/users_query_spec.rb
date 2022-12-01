# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECF::UsersQuery, :with_support_for_ect_examples do
  subject { described_class.new.all }

  it "returns a list of users" do
    included_records = records_for(
      cip_ect_only,
      cip_ect_reg_complete,
      fip_ect_only,
      fip_mentor_only,
      cip_mentor_only,
      cip_ect_updated_a_year_ago,
    )

    expect(subject).to all(be_a(User))
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

    expect(subject).to match_array included_records
  end

  it "includes past 'Withdrawn' participants" do
    included_records = records_for(
      fip_ect_withdrawn,
    )

    expect(subject).to match_array included_records
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
    let(:filter_date) { cip_ect_updated_a_year_ago.updated_at + 1.month }

    subject { described_class.new(updated_since: filter_date).all }

    it "returns a list of users with updated_at timestamps later than the supplied one" do
      included_records = records_for(
        cip_ect_only,
        cip_ect_reg_complete,
        fip_ect_only,
        fip_mentor_only,
        cip_mentor_only,
      )

      excluded_records = records_for(
        cip_ect_updated_a_year_ago,
      )

      expect(subject).to match_array included_records
      expect(subject).not_to include(*excluded_records)
    end
  end

  context "when filtering by email" do
    let(:filter_email) { cip_ect_only.user.email }

    subject { described_class.new(email: filter_email).all }

    it "it only returns users with the matching email address" do
      included_records = records_for(
        cip_ect_only,
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
    it "includes user withdrawn before we added induction_records once" do
      included_records = records_for(
        ect_with_no_induction_record,
      )

      # found by user query but turned into type: "other" by serializer so ignored by Support ECTs
      expect(subject).to match_array included_records
    end

    it "includes user who is a second year ECT and is now a Mentor once" do
      included_records = records_for(
        fip_ect_then_mentor[:ect_profile],
        fip_ect_then_mentor[:mentor_profile],
      )

      # both have the same user so both are included but only 1 record is returned
      # It is the job of the serializer to pick the correct participant_profile to use
      expect(subject).to match_array [included_records.first]
      expect(subject).to match_array [included_records.second]
    end

    it "includes user with a corrupt induction record history" do
      included_records = records_for(
        cip_ect_with_corrupt_history,
      )

      expect(subject).to match_array included_records
    end

    it "includes a FIP ECT with no identity" do
      included_records = records_for(
        fip_ect_with_no_identity,
      )

      expect(subject).to match_array included_records
    end

    it "includes a FIP ECT with a different identity for some induction records once only" do
      included_records = records_for(
        fip_ect_with_different_identity[:correct_profile],
        fip_ect_with_different_identity[:wrong_profile],
      )

      expect(subject).to match_array included_records
    end
  end

private

  def records_for(*profiles)
    profiles.map(&:user)
  end
end
