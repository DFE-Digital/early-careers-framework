# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ActiveCountByPartnership do
  let(:partnership) { create(:partnership) }
  let(:lead_provider) { partnership.lead_provider }
  let(:partnerships) { [partnership] }

  describe "#call" do
    subject(:counts) { described_class.call(partnerships:, lead_provider:) }

    it "returns a count of 0 by default" do
      expect(counts[partnership.id]).to eq(ect_count: 0, mentor_count: 0)
    end

    it "counts active ECTs and Mentors" do
      create_profile_with_induction_record(:ect_participant_profile, partnership)
      create_profile_with_induction_record(:mentor_participant_profile, partnership)
      create_profile_with_induction_record(:mentor_participant_profile, partnership)

      expect(counts[partnership.id]).to include(ect_count: 1, mentor_count: 2)
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

        is_expected.not_to have_key(partnership.id)
        expect(counts[latest_partnership.id]).to include(ect_count: 1)
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
        expect(counts[partnership.id]).to include(ect_count: 1)
        is_expected.not_to have_key(another_partnership.id)
      end

      context "when querying as the other lead provider" do
        let(:lead_provider) { another_partnership.lead_provider }

        it "includes participants only for the partnership of the provided lead provider" do
          expect(counts[another_partnership.id]).to include(ect_count: 1)
          is_expected.not_to have_key(partnership.id)
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
