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

  describe "#save_and_dedupe_participant" do
    let(:user) { create(:user, :teacher) }
    let(:instance) { build(:npq_application, user:) }

    subject(:save_and_dedupe_participant) { instance.save_and_dedupe_participant }

    it { expect { save_and_dedupe_participant }.to change(NPQApplication, :count).by(1) }
    it { expect { save_and_dedupe_participant }.not_to change(ParticipantIdChange, :count) }
    it { is_expected.to eq(true) }

    context "when a participant with the same TRN exists" do
      let(:duplicate_trn) { user.teacher_profile.trn }

      before do
        create(:user, :teacher).tap { |user| user.teacher_profile.update!(trn: duplicate_trn) }
      end

      it { expect { save_and_dedupe_participant }.to change(NPQApplication, :count).by(1) }
      it { expect { save_and_dedupe_participant }.to change(ParticipantIdChange, :count).by(1) }
      it { is_expected.to eq(true) }
    end
  end

  describe "#eligible_for_dfe_funding" do
    let(:npq_course) { create(:npq_leadership_course) }
    let(:different_npq_course) { create(:npq_specialist_course) }

    before do
      create(:npq_leadership_schedule, :with_npq_milestones)
    end

    RSpec.shared_examples "when funded place is not set" do
      context "when first and only application is eligible" do
        let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: nil) }

        it { is_expected.to be_truthy }
      end

      context "when first and only application is not eligible" do
        let(:npq_application) { create(:npq_application, eligible_for_funding: false, funded_place: nil) }

        it { is_expected.to be_falsey }
      end

      context "when second application is also eligible for funding" do
        let(:npq_application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            funded_place: nil,
            npq_course:,
          )
        end

        before do
          create(
            :npq_application,
            :accepted,
            participant_identity: npq_application.participant_identity,
            eligible_for_funding: true,
            funded_place: nil,
            npq_course: npq_application.npq_course,
            npq_lead_provider: npq_application.npq_lead_provider,
          )
        end

        it { is_expected.to be_falsey }
      end

      context "when second application is eligible for funding but first was not" do
        let(:npq_application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            funded_place: nil,
            npq_course:,
          )
        end

        before do
          create(
            :npq_application,
            :accepted,
            participant_identity: npq_application.participant_identity,
            eligible_for_funding: false,
            funded_place: nil,
            npq_course: npq_application.npq_course,
            npq_lead_provider: npq_application.npq_lead_provider,
          )
        end

        it { is_expected.to be_truthy }
      end

      context "when second application is for a different course which is eligible for funding" do
        let(:npq_application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            funded_place: nil,
            npq_course:,
          )
        end

        before do
          create(:npq_specialist_schedule, :with_npq_milestones)

          create(
            :npq_application,
            :accepted,
            participant_identity: npq_application.participant_identity,
            eligible_for_funding: true,
            funded_place: nil,
            npq_course: different_npq_course,
            npq_lead_provider: npq_application.npq_lead_provider,
          )
        end

        it { is_expected.to be_truthy }
      end

      context "when it is the only accepted application" do
        let(:course) { create(:npq_leadership_course) }

        let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: nil, npq_course: course) }

        before do
          create(:npq_leadership_schedule)

          NPQ::Application::Accept.new(npq_application:).call
        end

        it { is_expected.to be_truthy }
      end
    end

    RSpec.shared_examples "when funded place is set to true" do
      context "when first and only application is eligible" do
        let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: true) }

        it { is_expected.to be_truthy }
      end

      context "when second application is eligible for funding" do
        let(:npq_application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            funded_place: true,
            npq_course:,
          )
        end

        before do
          create(
            :npq_application,
            :accepted,
            participant_identity: npq_application.participant_identity,
            eligible_for_funding: true,
            funded_place: true,
            npq_course: npq_application.npq_course,
            npq_lead_provider: npq_application.npq_lead_provider,
          )
        end

        it { is_expected.to be_falsey }
      end

      context "when second application is eligible for funding but first was not" do
        let(:npq_application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            funded_place: true,
            npq_course:,
          )
        end

        before do
          create(
            :npq_application,
            :accepted,
            participant_identity: npq_application.participant_identity,
            eligible_for_funding: false,
            funded_place: false,
            npq_course: npq_application.npq_course,
            npq_lead_provider: npq_application.npq_lead_provider,
          )
        end

        it { is_expected.to be_truthy }
      end

      context "when second application is for a different course which is eligible for funding" do
        let(:npq_application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            funded_place: true,
            npq_course:,
          )
        end

        before do
          create(:npq_specialist_schedule, :with_npq_milestones)

          create(
            :npq_application,
            :accepted,
            participant_identity: npq_application.participant_identity,
            eligible_for_funding: true,
            funded_place: true,
            npq_course: different_npq_course,
            npq_lead_provider: npq_application.npq_lead_provider,
          )
        end

        it { is_expected.to be_truthy }
      end

      context "when it is the only accepted application" do
        let(:course) { create(:npq_leadership_course) }

        let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: true, npq_course: course) }

        before do
          create(:npq_leadership_schedule)

          NPQ::Application::Accept.new(npq_application:).call
        end

        it { is_expected.to be_truthy }
      end
    end

    context "without funded_place" do
      subject { npq_application.eligible_for_dfe_funding }

      it_behaves_like "when funded place is not set"

      it_behaves_like "when funded place is set to true"

      context "when funded place is set to false" do
        context "when first and only application is not eligible and funded place is false" do
          let(:npq_application) { create(:npq_application, eligible_for_funding: false, funded_place: false) }

          it { is_expected.to be_falsey }
        end

        context "when first and only application is eligible and funded place is false" do
          let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: false) }

          it { is_expected.to be_truthy }
        end

        context "when second application is not eligible for funding" do
          let(:npq_application) do
            create(
              :npq_application,
              eligible_for_funding: true,
              funded_place: true,
              npq_course:,
            )
          end

          before do
            create(
              :npq_application,
              :accepted,
              participant_identity: npq_application.participant_identity,
              eligible_for_funding: true,
              funded_place: false,
              npq_course: npq_application.npq_course,
              npq_lead_provider: npq_application.npq_lead_provider,
            )
          end

          it { is_expected.to be_truthy }
        end

        context "when second application is eligible for funding" do
          let(:npq_application) do
            create(
              :npq_application,
              eligible_for_funding: true,
              funded_place: false,
              npq_course:,
            )
          end

          before do
            create(
              :npq_application,
              :accepted,
              participant_identity: npq_application.participant_identity,
              eligible_for_funding: true,
              funded_place: false,
              npq_course: npq_application.npq_course,
              npq_lead_provider: npq_application.npq_lead_provider,
            )
          end

          it { is_expected.to be_truthy }
        end

        context "when it is the only accepted application" do
          let(:course) { create(:npq_leadership_course) }

          let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: false, npq_course: course) }

          before do
            create(:npq_leadership_schedule)

            NPQ::Application::Accept.new(npq_application:).call
          end

          it { is_expected.to be_truthy }
        end
      end
    end

    context "with funded_place" do
      subject { npq_application.eligible_for_dfe_funding(with_funded_place: true) }

      it_behaves_like "when funded place is not set"

      it_behaves_like "when funded place is set to true"

      context "when funded place is set to false" do
        context "when first and only application is not eligible and funded place is false" do
          let(:npq_application) { create(:npq_application, eligible_for_funding: false, funded_place: false) }

          it { is_expected.to be_falsey }
        end

        context "when first and only application is eligible and funded place is false" do
          let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: false) }

          it { is_expected.to be_falsey }
        end

        context "when second application is not eligible for funding" do
          let(:npq_application) do
            create(
              :npq_application,
              eligible_for_funding: true,
              funded_place: true,
              npq_course:,
            )
          end

          before do
            create(
              :npq_application,
              :accepted,
              participant_identity: npq_application.participant_identity,
              eligible_for_funding: true,
              funded_place: false,
              npq_course: npq_application.npq_course,
              npq_lead_provider: npq_application.npq_lead_provider,
            )
          end

          it { is_expected.to be_truthy }
        end

        context "when both applications are not eligible for funding" do
          let(:npq_application) do
            create(
              :npq_application,
              eligible_for_funding: true,
              funded_place: false,
              npq_course:,
            )
          end

          before do
            create(
              :npq_application,
              :accepted,
              participant_identity: npq_application.participant_identity,
              eligible_for_funding: true,
              funded_place: false,
              npq_course: npq_application.npq_course,
              npq_lead_provider: npq_application.npq_lead_provider,
            )
          end

          it { is_expected.to be_falsey }
        end

        context "when it is the only accepted application" do
          let(:course) { create(:npq_leadership_course) }

          let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: false, npq_course: course) }

          before do
            create(:npq_leadership_schedule)

            NPQ::Application::Accept.new(npq_application:).call
          end

          it { is_expected.to be_falsey }
        end
      end
    end

    context "when transient_previously_funded is declared on the model" do
      let(:npq_application) { create(:npq_application, eligible_for_funding: true) }

      before do
        def npq_application.transient_previously_funded
          false
        end
      end

      it "does not make a query to determine the previously_funded status" do
        expect(NPQApplication).not_to receive(:connection)
        expect(npq_application.eligible_for_dfe_funding).to be(true)
      end

      context "when transient_previously_funded is true" do
        before do
          def npq_application.transient_previously_funded
            true
          end
        end

        it "does not make a query to determine the previously_funded status" do
          expect(NPQApplication).not_to receive(:connection)
          expect(npq_application.eligible_for_dfe_funding).to be(false)
        end
      end
    end
  end

  describe "#ineligible_for_funding_reason" do
    context "when funded place is not set" do
      context "it is eligible for funding" do
        subject { create(:npq_application, eligible_for_funding: true, funded_place: nil) }

        it "returns nil" do
          expect(subject.ineligible_for_funding_reason).to be_nil
        end
      end

      context "when school/course combo is not applicable" do
        subject { create(:npq_application, eligible_for_funding: false, funded_place: nil) }

        it "returns establishment-ineligible" do
          expect(subject.ineligible_for_funding_reason).to eql("establishment-ineligible")
        end
      end

      context "when there is a previously accepted application" do
        let(:npq_course) { create(:npq_leadership_course) }

        subject { create(:npq_application, eligible_for_funding: true, npq_course:, funded_place: nil) }

        before do
          create(:npq_leadership_schedule, :with_npq_milestones)

          create(
            :npq_application,
            :accepted,
            participant_identity: subject.participant_identity,
            eligible_for_funding: true,
            funded_place: nil,
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

        subject { create(:npq_application, eligible_for_funding: true, funded_place: nil, npq_course: npq_ehco_course) }

        before do
          create(:npq_aso_schedule)
          create(:npq_ehco_schedule)

          create(
            :npq_application,
            :accepted,
            participant_identity: subject.participant_identity,
            eligible_for_funding: true,
            funded_place: nil,
            npq_course: npq_aso_course,
            npq_lead_provider: subject.npq_lead_provider,
          )
        end

        it "returns previously-funded" do
          expect(subject.ineligible_for_funding_reason).to eql("previously-funded")
        end
      end
    end

    context "when funded place is set to true" do
      context "it is eligible for funding" do
        subject { create(:npq_application, eligible_for_funding: true, funded_place: true) }

        it "returns nil" do
          expect(subject.ineligible_for_funding_reason).to be_nil
        end
      end

      context "when there is a previously accepted application" do
        let(:npq_course) { create(:npq_leadership_course) }

        subject { create(:npq_application, eligible_for_funding: true, npq_course:, funded_place: true) }

        before do
          create(:npq_leadership_schedule, :with_npq_milestones)

          create(
            :npq_application,
            :accepted,
            participant_identity: subject.participant_identity,
            eligible_for_funding: true,
            funded_place: true,
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

        subject { create(:npq_application, eligible_for_funding: true, funded_place: true, npq_course: npq_ehco_course) }

        before do
          create(:npq_aso_schedule)
          create(:npq_ehco_schedule)

          create(
            :npq_application,
            :accepted,
            participant_identity: subject.participant_identity,
            eligible_for_funding: true,
            funded_place: true,
            npq_course: npq_aso_course,
            npq_lead_provider: subject.npq_lead_provider,
          )
        end

        it "returns previously-funded" do
          expect(subject.ineligible_for_funding_reason).to eql("previously-funded")
        end
      end
    end

    context "when funded place is set to false" do
      context "it is eligible for funding even though funded place is not" do
        subject { create(:npq_application, eligible_for_funding: true, funded_place: false) }

        it "returns nil" do
          expect(subject.ineligible_for_funding_reason).to be_nil
        end
      end

      context "when school/course combo is not applicable" do
        subject { create(:npq_application, eligible_for_funding: false, funded_place: false) }

        it "returns establishment-ineligible" do
          expect(subject.ineligible_for_funding_reason).to eql("establishment-ineligible")
        end
      end

      context "when there is a previously ineligible accepted application" do
        let(:npq_course) { create(:npq_leadership_course) }

        subject { create(:npq_application, eligible_for_funding: true, npq_course:, funded_place: false) }

        before do
          create(:npq_leadership_schedule, :with_npq_milestones)

          create(
            :npq_application,
            :accepted,
            participant_identity: subject.participant_identity,
            eligible_for_funding: true,
            funded_place: false,
            npq_course: subject.npq_course,
            npq_lead_provider: subject.npq_lead_provider,
          )
        end

        it "returns nil" do
          expect(subject.ineligible_for_funding_reason).to be_nil
        end
      end

      context "when there is a previously ineligible accepted ASO and applying for EHC0" do
        let(:npq_aso_course) { create(:npq_aso_course) }
        let(:npq_ehco_course) { create(:npq_ehco_course) }

        subject { create(:npq_application, eligible_for_funding: true, funded_place: false, npq_course: npq_ehco_course) }

        before do
          create(:npq_aso_schedule)
          create(:npq_ehco_schedule)

          create(
            :npq_application,
            :accepted,
            participant_identity: subject.participant_identity,
            eligible_for_funding: true,
            funded_place: false,
            npq_course: npq_aso_course,
            npq_lead_provider: subject.npq_lead_provider,
          )
        end

        it "returns nil" do
          expect(subject.ineligible_for_funding_reason).to be_nil
        end
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

  describe "#latest_completed_participant_declaration" do
    context "when participant_declaration not exist" do
      let(:npq_application) { create(:npq_application) }

      it "returns nil" do
        result = npq_application.latest_completed_participant_declaration
        expect(result).to eq(nil)
      end
    end
  end

  describe "Change logs for NPQ applications" do
    before do
      PaperTrail.config.enabled = true
    end

    after do
      PaperTrail.config.enabled = false
    end

    describe "#change_log" do
      subject do
        create :npq_application, eligible_for_funding: false, funding_eligiblity_status_code: "marked_ineligible_by_policy", works_in_school: true
      end

      it "returns a list of changes for `eligible_for_funding`" do
        expect { subject.update!(eligible_for_funding: true) }
          .to change { subject.change_logs.count }.by(1)
      end

      it "returns a list of changes for `funding_eligiblity_status_code`" do
        expect { subject.update!(funding_eligiblity_status_code: "re_register") }
          .to change { subject.change_logs.count }.by(1)
      end

      it "returns an empty list if any of the attributes is changed" do
        expect { subject.update!(works_in_school: false) }
          .to change { subject.change_logs.count }.by(0)
      end

      it "returns a list of changes grouped" do
        expect { subject.update!(eligible_for_funding: true, funding_eligiblity_status_code: "re_register") }
          .to change { subject.change_logs.count }.by(1)
      end

      it "sorts the changes by created_at" do
        subject.update!(eligible_for_funding: true, funding_eligiblity_status_code: "re_register")
        subject.update!(eligible_for_funding: false, funding_eligiblity_status_code: "marked_ineligible_by_policy")
        subject.update!(eligible_for_funding: true)
        subject.update!(eligible_for_funding: false)

        change_logs = subject.change_logs
        created_ats = change_logs.map(&:created_at)

        expect(created_ats).to eq(created_ats.sort.reverse)
      end

      it "return a list of Version objects" do
        subject.update!(eligible_for_funding: true, funding_eligiblity_status_code: "re_register")

        expect(subject.change_logs).to all(satisfy { |change_log| change_log.is_a?(PaperTrail::Version) })
      end
    end

    describe "changelog configuration via Papertrail" do
      subject do
        create(:npq_application, works_in_school: true)
      end

      it "does not create an entry if attribute is not changed" do
        expect { subject.update!(works_in_school: false) }
          .to_not change { subject.versions.where_attribute_changes("eligible_for_funding").count }
      end

      context "with changes on eligible_for_funding" do
        before do
          subject.update! eligible_for_funding: true
        end

        it "creates an entry if attribute is changed" do
          expect { subject.update!(eligible_for_funding: false) }
            .to change { subject.versions.where_attribute_changes("eligible_for_funding").count }.by(1)
        end

        it "does not create an entry if attribute is the same" do
          expect { subject.update!(eligible_for_funding: true) }
            .to_not change { subject.versions.where_attribute_changes("eligible_for_funding").count }
        end
      end

      context "with changes on funding_eligiblity_status_code" do
        before do
          subject.update! funding_eligiblity_status_code: "marked_ineligible_by_policy"
        end

        it "creates an entry if attribute is changed" do
          expect { subject.update!(funding_eligiblity_status_code: "re_register") }
            .to change { subject.versions.where_attribute_changes("funding_eligiblity_status_code").count }.by(1)
        end

        it "does not create an entry if attribute is the same" do
          expect { subject.update!(funding_eligiblity_status_code: "marked_ineligible_by_policy") }
            .to_not change { subject.versions.where_attribute_changes("funding_eligiblity_status_code").count }
        end
      end
    end
  end
end
