# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ActiveByPartnership do
  let(:partnership) { create(:partnership) }
  let(:lead_provider) { partnership.lead_provider }
  let(:partnerships) { [partnership] }

  describe "#call" do
    subject { described_class.call(partnerships:, lead_provider:) }

    it "does not set a value if there are no participants found" do
      is_expected.not_to include([partnership.id, "ParticipantProfile::ECT"])
      is_expected.not_to include([partnership.id, "ParticipantProfile::Mentor"])
    end

    it "counts active ECTs and Mentors" do
      create_profile_with_induction_record(:ect_participant_profile, partnership)
      create_profile_with_induction_record(:mentor_participant_profile, partnership)
      create_profile_with_induction_record(:mentor_participant_profile, partnership)

      is_expected.to include([partnership.id, "ParticipantProfile::ECT"] => 1)
      is_expected.to include([partnership.id, "ParticipantProfile::Mentor"] => 2)
    end

    it "does not include withdrawn records" do
      create_profile_with_induction_record(:ect_participant_profile, partnership, :withdrawn_record)

      is_expected.to be_empty
    end

    it "does not include participants from other partnerships" do
      another_partnership = create(:partnership)
      create_profile_with_induction_record(:ect_participant_profile, another_partnership)

      is_expected.to be_empty
    end

    it "does not include participants from partnerships with a challenged_at date" do
      partnership.update!(challenged_at: Time.zone.now)
      create_profile_with_induction_record(:ect_participant_profile, partnership)

      is_expected.to be_empty
    end

    it "does not include participants from partnerships with a challenge_reason" do
      partnership.update!(challenge_reason: :not_confirmed)
      create_profile_with_induction_record(:ect_participant_profile, partnership)

      is_expected.to be_empty
    end

    context "when there is another partnership (with the same lead provider)" do
      let(:latest_partnership) { create(:partnership, lead_provider: partnership.lead_provider) }
      let(:partnerships) { [partnership, latest_partnership] }

      it "includes a participant for only the latest partnership" do
        create_profile_with_induction_record(:ect_participant_profile, partnership).tap do |participant_profile|
          create(:induction_record, participant_profile:, partnership: latest_partnership)
        end

        is_expected.not_to include([partnership.id, "ParticipantProfile::ECT"])
        is_expected.to include([latest_partnership.id, "ParticipantProfile::ECT"] => 1)
      end
    end

    context "when there is another partnership (with a different lead provider)" do
      let(:another_partnership) { create(:partnership) }
      let(:partnerships) { [partnership, another_partnership] }

      before do
        create_profile_with_induction_record(:ect_participant_profile, partnership).tap do |participant_profile|
          create(:induction_record, participant_profile:, partnership: another_partnership)
        end
      end

      it "includes participants only for the partnership of the provided lead provider" do
        is_expected.to include([partnership.id, "ParticipantProfile::ECT"] => 1)
        is_expected.not_to include([another_partnership.id, "ParticipantProfile::ECT"])
      end

      context "when querying as the other lead provider" do
        let(:lead_provider) { another_partnership.lead_provider }

        it "includes participants only for the partnership of the provided lead provider" do
          is_expected.to include([another_partnership.id, "ParticipantProfile::ECT"] => 1)
          is_expected.not_to include([partnership.id, "ParticipantProfile::ECT"])
        end
      end
    end
  end

  def create_profile_with_induction_record(factory, partnership, *traits)
    create(factory, *traits).tap do |participant_profile|
      # We create multiple to ensure we don't double count participants.
      create_list(:induction_record, 2, participant_profile:, partnership:)
    end
  end
end
