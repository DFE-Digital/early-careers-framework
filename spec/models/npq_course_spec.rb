# frozen_string_literal: true

require "rails_helper"
RSpec.describe NPQCourse do
  describe ".schedule_for", :with_default_schedules do
    let(:npq_course) { build(:npq_course, identifier: identifier) }

    context "when a course is one of NPQCourse::LEADERSHIP_IDENTIFIER" do
      let(:identifier) { NPQCourse::LEADERSHIP_IDENTIFIER.sample }

      it "returns the defaut NPQ leadership schedule" do
        expect(described_class.schedule_for(npq_course))
          .to eq(Finance::Schedule::NPQLeadership.default)
      end
    end

    context "when a course is one of NPQCourse::SPECIALIST_IDENTIFIER" do
      let(:identifier) { NPQCourse::SPECIALIST_IDENTIFIER.sample }

      it "returns the defaut NPQ specialist schedule" do
        expect(described_class.schedule_for(npq_course)).to eq(Finance::Schedule::NPQSpecialist.default)
      end
    end

    context "when a course is Additional Support Offer" do
      let(:identifier) { "npq-additional-support-offer" }

      it "returns the defaut NPQ specialist schedule" do
        expect(described_class.schedule_for(npq_course)).to eq(Finance::Schedule::NPQSpecialist.default)
      end
    end

    context "with and unknown course identifier" do
      let(:identifier) { "unknown-course-identifier" }

      it {
        expect { described_class.schedule_for(npq_course) }
          .to raise_error(ArgumentError, "Invalid course identifier")
      }
    end
  end
end
