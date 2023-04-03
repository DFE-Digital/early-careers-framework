# frozen_string_literal: true

require "rails_helper"
RSpec.describe NPQCourse do
  describe "::schedule_for", :with_default_schedules do
    let(:npq_course) { build(:npq_course, identifier:) }
    let(:cohort) { Cohort.current }

    context "when a course is one of NPQCourse::LEADERSHIP_IDENTIFIER" do
      let(:identifier) { Finance::Schedule::NPQLeadership::IDENTIFIERS.sample }

      it "returns the default NPQ leadership schedule" do
        expect(described_class.schedule_for(npq_course:, cohort:))
          .to eq(Finance::Schedule::NPQLeadership.schedule_for(cohort:))
      end

      context "when requesting for next cohort" do
        let(:next_cohort) { Cohort.next || create(:cohort, :next) }

        it "uses next cohort schedule" do
          expect(described_class.schedule_for(npq_course:, cohort: next_cohort)).to eql(Finance::Schedule::NPQLeadership.schedule_for(cohort: next_cohort))
        end
      end
    end

    context "when a course is one of NPQCourse::SPECIALIST_IDENTIFIER" do
      let(:identifier) { Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample }

      it "returns the default NPQ specialist schedule" do
        expect(described_class.schedule_for(npq_course:, cohort:)).to eq(Finance::Schedule::NPQSpecialist.schedule_for(cohort:))
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
        expected_schedule = Finance::Schedule::NPQEhco.schedule_for(cohort:)

        expect(described_class.schedule_for(npq_course:)).to eq(expected_schedule)
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
