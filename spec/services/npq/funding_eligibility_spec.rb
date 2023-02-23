# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::FundingEligibility, :with_default_schedules do
  subject { described_class.new(trn:, get_an_identity_id:, npq_course_identifier: course_for_lookup.identifier) }

  let(:course_for_lookup) { npq_course }

  # Having this application in the DB makes sure that other user's applications
  # don't have an impact on the results. If we were failing to scope our search by
  # user then this accepted and funded application for the same course would produce
  # incorrect results
  let!(:unrelated_application) do
    create(
      :npq_application,
      lead_provider_approval_status: "accepted",
      eligible_for_funding: true,
      npq_course: course_for_lookup,
    )
  end

  let(:trn) { nil }
  let(:get_an_identity_id) { nil }

  describe "#call" do
    context "with a trn" do
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

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end

        context "with a get_an_identity_id" do
          let(:get_an_identity_id) { SecureRandom.uuid }
          let(:user) { create(:user, get_an_identity_id:) }

          context "that is not previously funded" do
            before do
              create(
                :npq_application,
                lead_provider_approval_status: "accepted",
                eligible_for_funding: false,
              )
            end

            it "returns falsey for previously_funded" do
              expect(subject.call[:previously_funded]).to be_falsey
            end

            it "returns falsey for previously_received_targeted_funding_support" do
              expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
            end
          end

          context "that is previously funded" do
            before do
              get_an_identity_application = create(
                :npq_application,
                user:,
                eligible_for_funding: true,
                teacher_reference_number_verified: true,
                targeted_delivery_funding_eligibility: true,
                npq_course:,
              )
              NPQ::Application::Accept.new(npq_application: get_an_identity_application).call
            end

            it "returns truthy for previously_funded" do
              expect(subject.call[:previously_funded]).to be_truthy
            end

            it "returns truthy for previously_received_targeted_funding_support" do
              expect(subject.call[:previously_received_targeted_funding_support]).to be_truthy
            end
          end
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
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded for a different course" do
        let(:trn) { application.teacher_reference_number }
        let(:application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
          )
        end
        let(:npq_application_course) { application.npq_course }
        # Making sure they are completely separate courses
        let(:npq_course) { create(:npq_course, identifier: npq_application_course.identifier.reverse) }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded with targeted delivery funding" do
        let(:trn) { application.teacher_reference_number }
        let(:application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
            targeted_delivery_funding_eligibility: true,
          )
        end
        let(:npq_course) { application.npq_course }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns truthy for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_truthy
        end
      end

      context "when previously funded ASO and applying for EHCO" do
        let(:trn) { application.teacher_reference_number }
        let(:npq_course) { create(:npq_course, identifier: "npq-additional-support-offer") }
        let(:application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
            npq_course:,
          )
        end

        let!(:ehco_npq_course) { create(:npq_course, identifier: "npq-early-headship-coaching-offer") }

        let(:course_identifier_for_subject) { ehco_npq_course }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded with multiple teacher profiles" do
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
          create(:teacher_profile, trn:)
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded with targeted delivery funding but not accepted" do
        let(:trn) { application.teacher_reference_number }
        let(:application) do
          create(
            :npq_application,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
            targeted_delivery_funding_eligibility: true,
          )
        end
        let(:npq_course) { application.npq_course }

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when trn does not yield any teachers" do
        let(:trn) { "0000000" }
        let(:npq_course) { create(:npq_course) }

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end
    end

    context "with a get_an_identity_id" do
      let(:get_an_identity_id) { SecureRandom.uuid }
      let(:user) { create(:user, get_an_identity_id:) }

      context "when not previously funded" do
        let(:application) do
          create(
            :npq_application,
            user:,
            lead_provider_approval_status: "accepted",
            eligible_for_funding: false,
          )
        end
        let(:npq_course) { application.npq_course }

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded" do
        let(:application) do
          create(
            :npq_application,
            user:,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
          )
        end
        let(:npq_course) { application.npq_course }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded for a different course" do
        let(:application) do
          create(
            :npq_application,
            user:,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
          )
        end
        let(:npq_application_course) { application.npq_course }
        # Making sure they are completely separate courses
        let(:npq_course) { create(:npq_course, identifier: npq_application_course.identifier.reverse) }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded with targeted delivery funding" do
        let(:application) do
          create(
            :npq_application,
            user:,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
            targeted_delivery_funding_eligibility: true,
          )
        end
        let(:npq_course) { application.npq_course }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns truthy for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_truthy
        end
      end

      context "when previously funded ASO and applying for EHCO" do
        let(:npq_course) { create(:npq_course, identifier: "npq-additional-support-offer") }
        let(:application) do
          create(
            :npq_application,
            user:,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
            npq_course:,
          )
        end

        let!(:ehco_npq_course) { create(:npq_course, identifier: "npq-early-headship-coaching-offer") }

        let(:course_identifier_for_subject) { ehco_npq_course }

        before do
          NPQ::Application::Accept.new(npq_application: application).call
        end

        it "returns truthy for previously_funded" do
          expect(subject.call[:previously_funded]).to be_truthy
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when previously funded with targeted delivery funding but not accepted" do
        let(:application) do
          create(
            :npq_application,
            user:,
            eligible_for_funding: true,
            teacher_reference_number_verified: true,
            targeted_delivery_funding_eligibility: true,
          )
        end
        let(:npq_course) { application.npq_course }

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end

      context "when GAI ID does not yield any teachers" do
        let(:get_an_identity_id) { SecureRandom.uuid }
        let(:npq_course) { create(:npq_course) }

        it "returns falsey for previously_funded" do
          expect(subject.call[:previously_funded]).to be_falsey
        end

        it "returns falsey for previously_received_targeted_funding_support" do
          expect(subject.call[:previously_received_targeted_funding_support]).to be_falsey
        end
      end
    end
  end
end
