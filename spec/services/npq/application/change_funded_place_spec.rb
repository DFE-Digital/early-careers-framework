# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Application::ChangeFundedPlace do
  subject(:service) { described_class.new(params) }

  describe "#call" do
    let(:npq_application) { create(:npq_application, :accepted, eligible_for_funding: true) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
    let(:funding_cap) { 10 }
    let(:statement) do
      create(
        :npq_statement,
        :next_output_fee,
        cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
        cohort: npq_application.cohort,
      )
    end
    let!(:npq_contract) do
      create(
        :npq_contract,
        npq_lead_provider:,
        cohort: statement.cohort,
        course_identifier: npq_course.identifier,
        version: statement.contract_version,
        funding_cap:,
      )
    end

    let(:params) { { npq_application: } }

    context "when feature flag: `npq_capping` is active" do
      before { FeatureFlag.activate("npq_capping") }

      describe "sets `funded_place` to true" do
        before { params.merge!(funded_place: true) }

        it "sets the funded place to true" do
          npq_application.update! funded_place: false
          service.call

          expect(npq_application.reload.funded_place).to be_truthy
        end
      end

      describe "sets `funded_place` to false" do
        before { params.merge!(funded_place: false) }

        it "sets the funded place to true" do
          npq_application.update! funded_place: true
          service.call

          expect(npq_application.reload.funded_place).to be_falsey
        end
      end
    end

    context "when feature flag: `npq_capping` is not active" do
      before { FeatureFlag.deactivate("npq_capping") }

      context "when funded_place is true" do
        let(:funded_place) { false }

        it "does not set the funded place to true" do
          service.call

          expect(npq_application.reload.funded_place).to be_falsey
        end
      end
    end

    describe "validations" do
      before { FeatureFlag.activate("npq_capping") }
      let(:funded_place) { true }

      it "is invalid if the application has not been accepted" do
        npq_application.update!(lead_provider_approval_status: "pending")

        service.call
        expect(service.errors.messages_for(:npq_application)).to include("The application is not accepted (pending)")
      end

      it "is invalid if the application is not eligible for funding" do
        npq_application.update!(eligible_for_funding: false)

        service.call
        expect(service.errors.messages_for(:npq_application)).to include("The application is not eligible for funding (pending)")
      end

      describe "eligibility to set funded place to false" do
        let(:declaration) { create(:npq_participant_declaration) }
        let(:npq_application) { declaration.participant_profile.npq_application }
        let(:funded_place) { false }

        before do
          npq_application.update!(eligible_for_funding: true)
        end

        it "is not eligible if the application has voided declaration" do
          declaration.declaration_states.first.voided!
          service.call

          expect(service.errors.messages_for(:npq_application)).to include("Cannot remove funding as there is a voided declaration (pending)")
        end

        it "is not eligible if the application has awaiting claweback declaration" do
          declaration.declaration_states.first.awaiting_clawback!

          service.call

          expect(service.errors.messages_for(:npq_application)).to include("Cannot remove funding as there is an awaiting claw back declaration (pending)")
        end

        it "is not eligible if the application has awaiting clawed back declaration" do
          declaration.declaration_states.first.clawed_back!

          service.call

          expect(service.errors.messages_for(:npq_application)).to include("Cannot remove funding as there is a clawed back declaration (pending)")
        end
      end
    end
  end
end
