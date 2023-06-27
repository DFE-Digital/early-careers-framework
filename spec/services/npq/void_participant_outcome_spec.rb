# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::VoidParticipantOutcome do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:schedule) { NPQCourse.schedule_for(npq_course:) }
  let(:declaration_date) { schedule.milestones.find_by(declaration_type:).start_date }
  let(:npq_course) { create(:npq_leadership_course) }
  let(:declaration_type) { "completed" }
  let!(:participant_profile) do
    create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider, npq_course:)
  end
  let(:participant_declaration) do
    travel_to declaration_date do
      create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:, declaration_type:, declaration_date:, state: "paid", has_passed: true)
    end
  end

  before do
    create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
  end

  subject(:service) { described_class.new(participant_declaration) }

  describe "#call" do
    context "completed declaration" do
      it "creates new participant outcome record" do
        expect(participant_declaration.outcomes.count).to eql(1)

        travel_to declaration_date + 1.day do
          service.call
        end

        expect(participant_declaration.outcomes.count).to eql(2)
        expect(participant_declaration.outcomes.latest).to be_voided
      end
    end

    context "submitted declaration" do
      let(:declaration_type) { "started" }

      it "does not create participant outcome record" do
        expect(participant_declaration.outcomes.count).to eql(0)

        travel_to declaration_date + 1.day do
          service.call
        end

        expect(participant_declaration.outcomes.count).to eql(0)
      end
    end

    context "ehco course" do
      let!(:npq_ehco_schedule) { create(:npq_ehco_schedule) }
      let(:npq_course) { create(:npq_ehco_course) }

      it "does not create participant outcome record" do
        expect(participant_declaration.outcomes.count).to eql(0)

        travel_to declaration_date + 1.day do
          service.call
        end

        expect(participant_declaration.outcomes.count).to eql(0)
      end
    end

    context "aso course identifier" do
      let!(:npq_aso_schedule) { create(:npq_aso_schedule) }
      let(:npq_course) { create(:npq_aso_course) }

      it "does not create participant outcome record" do
        expect(participant_declaration.outcomes.count).to eql(0)

        travel_to declaration_date + 1.day do
          service.call
        end

        expect(participant_declaration.outcomes.count).to eql(0)
      end
    end
  end
end
