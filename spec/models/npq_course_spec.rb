# frozen_string_literal: true

require "rails_helper"
RSpec.describe NPQCourse do
  describe "::schedule_for", :with_default_schedules do
    let(:npq_course) { build(:npq_course, identifier:) }
    let(:cohort) { Cohort.previous }

    context "when a course is one of NPQCourse::LEADERSHIP_IDENTIFIER" do
      let(:identifier) { Finance::Schedule::NPQLeadership::IDENTIFIERS.sample }
      let!(:cohort_schedule) { create(:npq_leadership_schedule, cohort:) }

      it "returns the default NPQ leadership schedule" do
        expect(described_class.schedule_for(npq_course:, cohort:))
          .to eq(Finance::Schedule::NPQLeadership.default_for(cohort:))
      end

      context "when requesting for next cohort" do
        let(:next_cohort) { Cohort.next || create(:cohort, :next) }
        let!(:next_cohort_schedule) { create(:npq_leadership_schedule, cohort: next_cohort) }

        it "uses next cohort schedule" do
          expect(described_class.schedule_for(npq_course:, cohort: next_cohort)).to eql(next_cohort_schedule)
        end
      end
    end

    context "when a course is one of NPQCourse::SPECIALIST_IDENTIFIER" do
      let(:identifier) { Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample }
      let!(:cohort_schedule) { create(:npq_specialist_schedule, cohort:) }

      it "returns the default NPQ specialist schedule" do
        expect(described_class.schedule_for(npq_course:, cohort:)).to eq(Finance::Schedule::NPQSpecialist.default_for(cohort:))
      end
    end

    context "when a course is Additional Support Offer" do
      let(:identifier) { "npq-additional-support-offer" }

      it "returns the default NPQ support schedule" do
        expect(described_class.schedule_for(npq_course:)).to eq(Finance::Schedule::NPQSupport.default)
      end
    end

    context "when a course is Early Headship Coaching Offer" do
      let(:identifier) { "npq-early-headship-coaching-offer" }

      it "returns the default NPQ EHCO schedule" do
        expected_schedule = Finance::Schedule::NPQEhco.find_by(schedule_identifier: "npq-ehco-december")

        travel_to Date.new(Cohort.current.start_year, 12, 1) do
          expect(described_class.schedule_for(npq_course:)).to eq(expected_schedule)
        end
      end
    end

    context "with and unknown course identifier" do
      let(:identifier) { "unknown-course-identifier" }

      it {
        expect { described_class.schedule_for(npq_course:) }
          .to raise_error(ArgumentError, "Invalid course identifier")
      }
    end
  end
end
