# frozen_string_literal: true

require "rails_helper"
RSpec.describe NPQCourse do
  describe "::schedule_for", :with_default_schedules do
    let(:npq_course) { build(:npq_course, identifier:) }

    context "when a course is one of NPQCourse::LEADERSHIP_IDENTIFIER" do
      let(:identifier) { Finance::Schedule::NPQLeadership::IDENTIFIERS.sample }

      it "returns the default NPQ leadership schedule" do
        expect(described_class.schedule_for(npq_course:))
          .to eq(Finance::Schedule::NPQLeadership.default)
      end

      context "when requesting for cohort 2022" do
        let(:cohort_2022) { create(:cohort, :next) }
        let!(:schedule_2022) { create(:npq_leadership_schedule, cohort: cohort_2022) }

        it "uses 2022 schedule" do
          expect(described_class.schedule_for(npq_course:, cohort: cohort_2022)).to eql(schedule_2022)
        end
      end
    end

    context "when a course is one of NPQCourse::SPECIALIST_IDENTIFIER" do
      let(:identifier) { Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample }

      it "returns the default NPQ specialist schedule" do
        expect(described_class.schedule_for(npq_course:)).to eq(Finance::Schedule::NPQSpecialist.default)
      end
    end

    context "when a course is Additional Support Offer" do
      let(:identifier) { "npq-additional-support-offer" }

      it "returns the default NPQ support schedule" do
        expect(described_class.schedule_for(npq_course:)).to eq(Finance::Schedule::NPQSupport.default)
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
