# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::FundingEligibility, :with_default_schedules do
  subject { described_class.new(trn: trn, npq_course_identifier: npq_course.identifier) }

  describe "#call" do
    context "when not previously funded" do
      let(:trn) { application.teacher_reference_number }
      let(:application) do
        create(
          :npq_application,
          lead_provider_approval_status: "accepted",
          eligible_for_funding: false,
        )
      end
      let(:npq_course) { application.npq_course }

      it "returns falsey" do
        expect(subject.call[:previously_funded]).to be_falsey
      end
    end

    context "when previously funded" do
      let(:trn) { application.teacher_reference_number }
      let(:application) do
        create(
          :npq_application,
          eligible_for_funding: true,
          teacher_reference_number_verified: true,
        )
      end
      let(:npq_course) { application.npq_course }

      before do
        NPQ::Accept.new(npq_application: application).call
      end

      it "returns truthy" do
        expect(subject.call[:previously_funded]).to be_truthy
      end
    end

    context "when trn does not yield any teachers" do
      let(:trn) { "0000000" }
      let(:npq_course) { create(:npq_course) }

      subject { described_class.new(trn: trn, npq_course_identifier: npq_course.identifier) }

      it "returns falsey" do
        expect(subject.call[:previously_funded]).to be_falsey
      end
    end
  end
end
