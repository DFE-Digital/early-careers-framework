# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemoveSchoolMentorJob, :with_default_schedules do
  describe "#perform" do
    subject(:job) { described_class }
    let(:school_cohort) { create(:school_cohort, :fip) }
    let(:school) { school_cohort.school }
    let(:remove_on_date) { Time.zone.today }
    let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }

    before do
      Mentors::AddToSchool.call(mentor_profile:, school:)
      school.school_mentors.first.update!(remove_from_school_on: remove_on_date)
    end

    context "when there are school mentors to be removed" do
      it "removes the school mentor records" do
        expect { job.perform_now }.to change { SchoolMentor.count }.by(-1)
      end
    end

    context "when there are school mentors to be removed in the future" do
      let(:remove_on_date) { 1.day.from_now.to_date }

      it "does not remove the school mentors records" do
        expect { job.perform_now }.not_to change { SchoolMentor.count }
      end
    end
  end
end
