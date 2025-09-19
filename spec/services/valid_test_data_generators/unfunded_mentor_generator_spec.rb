# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::UnfundedMentorGenerator do
  let(:cohort) { create(:cohort, :current) }
  let(:lead_provider) { create(:lead_provider) }

  let(:instance) { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    let(:number) { 1 }
    subject(:generate) { instance.call(number:) }

    context "when the lead provider does not have a partnership for the cohort" do
      it { expect { generate }.not_to change(ParticipantProfile, :count) }
    end

    context "when the cohort has a default schedule and the lead provider has a school" do
      before do
        create(:local_authority)
        create(:partnership, cohort:, lead_provider:)
      end

      it { expect { generate }.to change(Api::V3::ECF::UnfundedMentorsQuery.new(lead_provider:, params: {}).unfunded_mentors, :size).by(1) }

      context "when creating multiple participants" do
        let(:number) { 5 }

        it { expect { generate }.to change(Api::V3::ECF::UnfundedMentorsQuery.new(lead_provider:, params: {}).unfunded_mentors, :size).by(number) }
      end
    end
  end
end
