# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::AmendParticipantCohort, type: :model do
  let(:npq_application) { create(:npq_application, cohort: cohort_previous) }
  let(:npq_application_id) { npq_application.id }

  let!(:cohort_current) { Cohort.current }
  let(:cohort_previous) { Cohort.previous }

  let(:target_cohort_start_year) { 2021 }

  subject { described_class.new(npq_application_id:, target_cohort_start_year:) }

  describe "validations" do
    context "when the NPQ application id is blank" do
      let(:npq_application_id) {}
      it { is_expected.to validate_presence_of(:npq_application_id) }
    end

    context "when the NPQ application id does not exist" do
      let(:npq_application_id) { "does-not-exist" }

      it "returns an error message" do
        expect(subject).to be_invalid
        expect(subject.errors.messages_for(:npq_application)).to include("Enter a valid NPQ application ID")
      end
    end

    context "when the target_cohort_start_year is blank" do
      let(:target_cohort_start_year) {}
      it { is_expected.to validate_presence_of(:target_cohort_start_year) }
    end

    context "when the target_cohort does not exist for the start year" do
      let(:target_cohort_start_year) { 2018 }

      it "returns an error message" do
        expect(subject).to be_invalid
        expect(subject.errors.messages_for(:target_cohort)).to include("starting on 2018 not setup on the service")
      end
    end

    context "when there are declarations set on the profile" do
      let!(:npq_application) { create(:npq_application, :accepted, :with_started_declaration) }
      it "returns an error message" do
        expect(subject).to be_invalid
        expect(subject.errors.messages_for(:base)).to include("The participant must have no declarations")
      end
    end

    context "when the target cohort is already set on the NPQ application" do
      it "returns an error message" do
        expect(subject).to be_invalid
        expect(subject.errors.messages_for(:target_cohort_start_year)).to include("Invalid value. Must be different to 2021")
      end
    end
  end

  describe "#call" do
    let(:npq_application) { create(:npq_application, cohort: cohort_current) }

    context "when invalid" do
      let(:target_cohort_start_year) {}

      it "does not update the application" do
        expect { subject.call }.not_to change(npq_application, :cohort)
      end
    end

    context "when valid" do
      it "updates the cohort on the NPQ application to the target cohort" do
        expect { subject.call }.to change { npq_application.reload.cohort }.from(cohort_current).to(cohort_previous)
      end

      context "when a profile is attached to an NPQ application" do
        let(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }
        let(:npq_application) { create(:npq_application, :accepted, cohort: cohort_current, npq_course:) }

        let(:source_schedule) { Finance::Schedule::NPQSpecialist.schedule_for(cohort: cohort_current) }
        let(:target_schedule) { Finance::Schedule::NPQSpecialist.schedule_for(cohort: cohort_previous) }

        before do
          {
            npq_specialist_schedule: %w[npq-specialist-spring npq-specialist-autumn],
          }.each do |schedule_type, schedule_identifiers|
            schedule_identifiers.each do |schedule_identifier|
              create(schedule_type, cohort: cohort_previous, schedule_identifier:)
            end
          end
        end

        it "updates the cohort on the NPQ application to the target cohort" do
          expect { subject.call }.to change { npq_application.reload.cohort }.from(cohort_current).to(cohort_previous)
        end

        it "updates the schedule on the profile to the target cohort schedule" do
          participant_profile = npq_application.profile

          expect { subject.call }.to change { participant_profile.reload.schedule }.from(source_schedule).to(target_schedule)
        end
      end
    end
  end
end
