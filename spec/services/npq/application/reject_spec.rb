# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Application::Reject, :with_default_schedules do
  let(:npq_application) { create(:npq_application, :accepted) }
  let(:params) do
    {
      npq_application:,
    }
  end

  subject(:service) do
    described_class.new(params)
  end

  describe "#call" do
    let(:npq_application) { create(:npq_application) }

    describe "validations" do
      context "when the npq application is missing" do
        let(:npq_application) {}

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:npq_application)).to include("The property '#/npq_application' must be present")
        end
      end

      context "when the npq application is already rejected" do
        let(:npq_application) { create(:npq_application, :rejected) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:npq_application)).to include("This NPQ application has already been rejected")
        end
      end

      context "when the npq application is accepted" do
        let(:npq_application) { create(:npq_application, :accepted) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:npq_application)).to include("Once accepted an application cannot change state")
        end
      end
    end

    describe ".call" do
      it "marks the lead provider approval status as rejected" do
        expect { service.call }.to change { npq_application.reload.lead_provider_approval_status }.from("pending").to("rejected")
      end
    end
  end
end
