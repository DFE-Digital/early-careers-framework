# frozen_string_literal: true

RSpec.describe Finance::ChangeLeadProviderApprovalStatusForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:params) { { npq_application:, change_status_to_pending: "yes" } }

  let!(:cohort) { create :cohort }
  let!(:schedule) { create :npq_leadership_schedule, cohort: }
  let(:npq_course) { create :npq_course, identifier: "npq-senior-leadership" }
  let(:npq_lead_provider) { create :npq_lead_provider }

  describe "accepted to pending" do
    let(:npq_application) do
      create(
        :npq_application, :accepted,
        npq_lead_provider:,
        npq_course:,
        cohort:
      )
    end
    it { is_expected.to validate_inclusion_of(:change_status_to_pending).in_array(%w[yes no]) }

    describe ".save" do
      context "valid params" do
        it "should change status" do
          expect(form.save).to be true
          expect(npq_application.reload).to be_pending
        end
      end

      context "invalid params" do
        let(:params) { { npq_application:, change_status_to_pending: "" } }

        it "should not change status" do
          expect(form.save).to be false
          expect(npq_application.reload).to be_accepted
        end
      end
    end
  end

  describe "rejected to pending" do
    let(:npq_application) do
      create(
        :npq_application, :rejected,
        npq_lead_provider:,
        npq_course:,
        cohort:
      )
    end
    it { is_expected.to validate_inclusion_of(:change_status_to_pending).in_array(%w[yes no]) }

    describe ".save" do
      context "valid params" do
        it "should change status" do
          expect(form.save).to be true
          expect(npq_application.reload).to be_pending
        end
      end

      context "invalid params" do
        let(:params) { { npq_application:, change_status_to_pending: "" } }

        it "should not change status" do
          expect(form.save).to be false
          expect(npq_application.reload).to be_rejected
        end
      end
    end
  end
end
