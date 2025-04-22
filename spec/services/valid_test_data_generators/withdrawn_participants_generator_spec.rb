# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::WithdrawnParticipantsGenerator do
  let(:cohort) { create(:cohort, :current) }
  let(:cpd_lead_provider) { lead_provider.cpd_lead_provider }
  let(:lead_provider) { create(:lead_provider) }
  let(:programme_types) { %i[fip cip design_our_own school_funded_fip] }

  let(:instance) { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    let(:count) { 1 }
    subject(:generate) { instance.call(count:) }

    before do
      create(:partnership, cohort:, lead_provider:)
      create(:ecf_statement, :next_output_fee, cpd_lead_provider:, cohort:)
    end

    it { expect { generate }.to change(ParticipantProfile::ECT, :count).by(count * programme_types.count) }
    it { expect { generate }.to change(ParticipantProfile::Mentor, :count).by(count * programme_types.count) }

    it "creates a partially trained and withdrawn ECT" do
      generate

      created_ect = ParticipantProfile::ECT.order(created_at: :asc).first

      expect(created_ect.training_status).to eq("withdrawn")
      expect(created_ect.latest_induction_record.training_status).to eq("withdrawn")
      expect(created_ect.latest_induction_record.cohort).to eq(cohort)
      expect(created_ect.participant_declarations).to be_present
      expect(created_ect.participant_declarations.map(&:cohort)).to all(eq(cohort))
    end

    it "creates a partially trained and withdrawn Mentor" do
      generate

      created_ect = ParticipantProfile::Mentor.order(created_at: :asc).first

      expect(created_ect.training_status).to eq("withdrawn")
      expect(created_ect.latest_induction_record.training_status).to eq("withdrawn")
      expect(created_ect.latest_induction_record.cohort).to eq(cohort)
      expect(created_ect.participant_declarations).to be_present
      expect(created_ect.participant_declarations.map(&:cohort)).to all(eq(cohort))
    end

    context "when creating multiple participants" do
      let(:count) { 2 }

      it { expect { generate }.to change(ParticipantProfile::ECT, :count).by(count * programme_types.count) }
      it { expect { generate }.to change(ParticipantProfile::Mentor, :count).by(count * programme_types.count) }
    end
  end
end
