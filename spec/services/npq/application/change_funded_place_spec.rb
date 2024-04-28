# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Application::ChangeFundedPlace do
  subject(:service) { described_class.new(params) }

  describe "#call" do
    let(:npq_application) { create(:npq_application, :accepted, eligible_for_funding: true) }
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

    # describe "validations" do
    #   context "when the npq application is missing" do
    #     let(:npq_application) {}
    #
    #     it "is invalid and returns an error message" do
    #       is_expected.to be_invalid
    #
    #       expect(service.errors.messages_for(:npq_application)).to include("The entered '#/npq_application' is missing from your request. Check details and try again.")
    #     end
    #   end
    #
    #   context "when the npq application is already accepted" do
    #     let(:npq_application) { create(:npq_application, :accepted) }
    #
    #     it "is invalid and returns an error message" do
    #       is_expected.to be_invalid
    #
    #       expect(service.errors.messages_for(:npq_application)).to include("This NPQ application has already been accepted")
    #     end
    #   end
    #
    #   context "when the npq application is rejected" do
    #     let(:npq_application) { create(:npq_application, :rejected) }
    #
    #     it "is invalid and returns an error message" do
    #       is_expected.to be_invalid
    #
    #       expect(service.errors.messages_for(:npq_application)).to include("Once rejected an application cannot change state")
    #     end
    #   end
    #
    #   context "when the existing data is invalid" do
    #     let(:npq_application) { create(:npq_application) }
    #
    #     it "throws ActiveRecord::RecordInvalid" do
    #       npq_application.eligible_for_funding = nil
    #       expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
    #     end
    #   end
    # end
  end
end
