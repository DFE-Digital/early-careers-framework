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
        }.to have_enqueued_job(NPQ::StreamBigQueryEnrollmentJob).once
      end
    end

    context "when lead_provider_approval_status is modified" do
      it "fires NPQ::StreamBigQueryEnrollmentJob" do
        subject

        expect {
          subject.update(lead_provider_approval_status: "accepted")
        }.to have_enqueued_job(NPQ::StreamBigQueryEnrollmentJob).once
      end
    end

    context "when cohort_id is modified" do
      let(:cohort) { create(:cohort, start_year: 2020) }

      it "fires NPQ::StreamBigQueryEnrollmentJob" do
        subject

        expect {
          subject.update(cohort:)
        }.to have_enqueued_job(NPQ::StreamBigQueryEnrollmentJob).once
      end
    end

    context "when record is touched" do
      it "does not fire NPQ::StreamBigQueryEnrollmentJob" do
        subject

        expect {
          subject.touch
        }.not_to have_enqueued_job(NPQ::StreamBigQueryEnrollmentJob)
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

    context "when transient_previously_funded is declared on the model" do
      subject { create(:npq_application, eligible_for_funding: true) }

      before do
        def subject.transient_previously_funded
          false
        end
      end

      it "does not make a query to determine the previously_funded status" do
        expect(NPQApplication).not_to receive(:connection)
        expect(subject.eligible_for_dfe_funding).to be(true)
      end

      context "when transient_previously_funded is true" do
        before do
          def subject.transient_previously_funded
            true
          end
        end

        it "does not make a query to determine the previously_funded status" do
          expect(NPQApplication).not_to receive(:connection)
          expect(subject.eligible_for_dfe_funding).to be(false)
        end
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

        NPQ::Application::Accept.new(npq_application: subject).call
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

    context "when transient_previously_funded is declared on the model" do
      subject { create(:npq_application, eligible_for_funding: false) }

      before do
        def subject.transient_previously_funded
          false
        end
      end

      it "does not make a query to determine the previously_funded status" do
        expect(NPQApplication).not_to receive(:connection)
        expect(subject.ineligible_for_funding_reason).to be("establishment-ineligible")
      end

      context "when transient_previously_funded is true" do
        before do
          def subject.transient_previously_funded
            true
          end
        end

        it "does not make a query to determine the previously_funded status" do
          expect(NPQApplication).not_to receive(:connection)
          expect(subject.ineligible_for_funding_reason).to be("previously-funded")
        end
      end
    end
  end

  describe "#self.participant_declaration_finder" do
    context "when participant_declaration not exist" do
      let(:npq_application) { create(:npq_application) }

      it "returns nil" do
        result = described_class.participant_declaration_finder(npq_application.participant_identity_id)
        expect(result).to eq(nil)
      end
    end

    context "when participant_declaration exist" do
      let(:participant_declaration) { create(:npq_participant_declaration) }
      let(:npq_application) { create(:npq_application, participant_identity_id: participant_declaration.participant_profile.participant_identity.id) }
      it "returns participant_declaration" do
        result = described_class.participant_declaration_finder(npq_application.participant_identity_id)
        expect(result).to eq(participant_declaration)
      end
    end
  end
end
