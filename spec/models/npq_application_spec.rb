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
    let(:npq_course) { create(:npq_leadership_course) }
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
          npq_course:,
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

    context "when second application which is eligble for funding but first was not" do
      subject do
        create(
          :npq_application,
          eligible_for_funding: true,
          npq_course:,
        )
      end

      before do
        create(
          :npq_application,
          :accepted,
          participant_identity: subject.participant_identity,
          eligible_for_funding: false,
          npq_course: subject.npq_course,
          npq_lead_provider: subject.npq_lead_provider,
        )
      end

      it "returns true" do
        expect(subject.eligible_for_dfe_funding).to be_truthy
      end
    end

    context "when second application is for a different course which is also eligble for funding" do
      subject do
        create(
          :npq_application,
          eligible_for_funding: true,
          npq_course:,
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

    context "when it is the only accepted application" do
      let(:course) { create(:npq_leadership_course) }

      subject { create(:npq_application, eligible_for_funding: true, npq_course: course) }

      before do
        create(:npq_leadership_schedule)

        AcceptNPQApplication.new(npq_application: subject).call
      end

      it "returns eligible for funding" do
        expect(subject.eligible_for_dfe_funding).to be_truthy
      end
    end
  end

  describe "#ineligible_for_funding_reason" do
    context "it is eligible for funding" do
      subject { create(:npq_application, eligible_for_funding: true) }

      it "returns nil" do
        expect(subject.ineligible_for_funding_reason).to be_nil
      end
    end

    context "when school/course combo is not applicable" do
      subject { create(:npq_application, eligible_for_funding: false) }

      it "returns establishment-ineligible" do
        expect(subject.ineligible_for_funding_reason).to eql("establishment-ineligible")
      end
    end

    context "when there is a previously accepted application" do
      let(:npq_course) { create(:npq_leadership_course) }

      subject { create(:npq_application, eligible_for_funding: true, npq_course:) }

      before do
        create(:npq_leadership_schedule, :with_npq_milestones)

        create(
          :npq_application,
          :accepted,
          participant_identity: subject.participant_identity,
          eligible_for_funding: true,
          npq_course: subject.npq_course,
          npq_lead_provider: subject.npq_lead_provider,
        )
      end

      it "returns previously-funded" do
        expect(subject.ineligible_for_funding_reason).to eql("previously-funded")
      end
    end

    context "when there is a previously accepted ASO and applying for EHC0" do
      let(:npq_aso_course) { create(:npq_aso_course) }
      let(:npq_ehco_course) { create(:npq_ehco_course) }

      subject { create(:npq_application, eligible_for_funding: true, npq_course: npq_ehco_course) }

      before do
        create(:npq_aso_schedule)
        create(:npq_ehco_schedule)

        create(
          :npq_application,
          :accepted,
          participant_identity: subject.participant_identity,
          eligible_for_funding: true,
          npq_course: npq_aso_course,
          npq_lead_provider: subject.npq_lead_provider,
        )
      end

      it "returns previously-funded" do
        expect(subject.ineligible_for_funding_reason).to eql("previously-funded")
      end
    end
  end
end
