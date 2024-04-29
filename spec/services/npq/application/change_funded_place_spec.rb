# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Application::ChangeFundedPlace do
  subject(:service) { described_class.new(params) }

  describe "#call" do
    let(:npq_application) do
      create(:npq_application,
             :accepted,
             eligible_for_funding: true,
             npq_course:,
             npq_lead_provider:)
    end
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
    let(:funding_cap) { 10 }
    let!(:statement) do
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
      before do
        FeatureFlag.activate("npq_capping")
        params.merge!(funded_place: true)
      end

      context "when funded_place is present" do
        before { params.merge!(funded_place: true) }

        it "is invalid if the application has not been accepted" do
          npq_application.update!(lead_provider_approval_status: "pending")

          service.call
          expect(service.errors.messages_for(:npq_application)).to include("You must accept the application before attempting to change the '#/funded_place' setting")
        end

        it "is invalid if the application is not eligible for funding" do
          npq_application.update!(eligible_for_funding: false)

          service.call
          expect(service.errors.messages_for(:npq_application)).to include("This participant is not eligible for funding. Contact us if you think this is wrong")
        end

        it "is invalid if the cohort does not accept capping and we set a funded place to true" do
          npq_contract.update!(funding_cap: nil)

          service.call
          expect(service.errors.messages_for(:npq_application)).to include("The cohort does not accept funded places (pending)")
        end

        it "is invalid if the cohort does not accept capping and we set a funded place to false" do
          params.merge!(funded_place: false)
          npq_contract.update!(funding_cap: nil)

          service.call
          expect(service.errors.messages_for(:npq_application)).to include("The cohort does not accept funded places (pending)")
        end

        context "when the application is not accepted" do
          let(:npq_application) { create(:npq_application, eligible_for_funding: true) }

          it "does not check for applicable declarations" do
            params.merge!(funded_place: false)

            service.call

            expect(service.errors.messages_for(:npq_application)).to include("You must accept the application before attempting to change the '#/funded_place' setting")
          end
        end

        describe "eligibility to set funded place to false" do
          let(:declaration) { create(:npq_participant_declaration) }
          let(:npq_application) { declaration.participant_profile.npq_application }

          before do
            npq_application.update!(eligible_for_funding: true)
            params.merge!(funded_place: false)
          end

          it "is not eligible if the application has submitted declaration" do
            declaration.submitted!

            service.call

            expect(service.errors.messages_for(:npq_application)).to include("You must void or claw back your declarations for this participant before being able to set '#/funded_place' to false")
          end

          it "is not eligible if the application has eligible declaration" do
            declaration.eligible!

            service.call

            expect(service.errors.messages_for(:npq_application)).to include("You must void or claw back your declarations for this participant before being able to set '#/funded_place' to false")
          end

          it "is not eligible if the application has payable back declaration" do
            declaration.payable!

            service.call

            expect(service.errors.messages_for(:npq_application)).to include("You must void or claw back your declarations for this participant before being able to set '#/funded_place' to false")
          end

          it "is not eligible if the application has a paid back declaration" do
            declaration.paid!

            service.call

            expect(service.errors.messages_for(:npq_application)).to include("You must void or claw back your declarations for this participant before being able to set '#/funded_place' to false")
          end
        end
      end

      context "when funded_place is not present" do
        before { params.merge!(funded_place: nil) }

        it "is invalid if funded_place is `nil`" do
          service.call

          expect(service.errors.messages_for(:npq_application)).to include("The entered '#/funded_place' is missing from your request. Check details and try again.")
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
