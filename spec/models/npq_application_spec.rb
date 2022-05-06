# frozen_string_literal: true

RSpec.describe NPQApplication, type: :model do
  it {
    is_expected.to define_enum_for(:headteacher_status).with_values(
      no: "no",
      yes_when_course_starts: "yes_when_course_starts",
      yes_in_first_two_years: "yes_in_first_two_years",
      yes_over_two_years: "yes_over_two_years",
      yes_in_first_five_years: "yes_in_first_five_years",
      yes_over_five_years: "yes_over_five_years",
    ).backed_by_column_of_type(:text)
  }

  describe "callbacks" do
    subject { create(:npq_application) }

    context "on creation" do
      it "fires NPQ::StreamBigQueryEnrollmentJob" do
        expect {
          subject
        }.to change(enqueued_jobs, :count).by(1)
      end
    end

    context "when lead_provider_approval_status is modified" do
      it "fires NPQ::StreamBigQueryEnrollmentJob" do
        subject

        expect {
          subject.update(lead_provider_approval_status: "accepted")
        }.to change(enqueued_jobs, :count).by(1)
      end
    end

    context "when record is touched" do
      it "does not fire NPQ::StreamBigQueryEnrollmentJob" do
        subject

        expect {
          subject.touch
        }.not_to change(enqueued_jobs, :count)
      end
    end
  end

  describe "#eligible_for_dfe_funding" do
    let(:npq_course) { create(:npq_leadship_course) }
    let(:different_npq_course) { create(:npq_specialist_course) }

    before do
      create(:npq_leadership_schedule, :with_npq_milestones)
    end

    context "when first and only application and is eligible" do
      subject { create(:npq_application, eligible_for_funding: true) }

      it "returns true" do
        expect(subject.eligible_for_dfe_funding).to be_truthy
      end
    end

    context "when first and only application and is not eligible" do
      subject { create(:npq_application, eligible_for_funding: false) }

      it "returns false" do
        expect(subject.eligible_for_dfe_funding).to be_falsey
      end
    end

    context "when second application which is also eligble for funding" do
      subject do
        create(
          :npq_application,
          eligible_for_funding: true,
          npq_course: npq_course,
        )
      end

      before do
        create(
          :npq_application,
          :accepted,
          participant_identity: subject.participant_identity,
          eligible_for_funding: true,
          npq_course: subject.npq_course,
          npq_lead_provider: subject.npq_lead_provider,
        )
      end

      it "returns false" do
        expect(subject.eligible_for_dfe_funding).to be_falsey
      end
    end

    context "when second application is for a different course which is also eligble for funding" do
      subject do
        create(
          :npq_application,
          eligible_for_funding: true,
          npq_course: npq_course,
        )
      end

      before do
        create(:npq_specialist_schedule, :with_npq_milestones)

        create(
          :npq_application,
          :accepted,
          participant_identity: subject.participant_identity,
          eligible_for_funding: true,
          npq_course: different_npq_course,
          npq_lead_provider: subject.npq_lead_provider,
        )
      end

      it "returns true" do
        expect(subject.eligible_for_dfe_funding).to be_truthy
      end
    end
  end
end
