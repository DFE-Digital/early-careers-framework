# frozen_string_literal: true

require "rails_helper"

RSpec.describe MentorMailer, type: :mailer do
  describe "#programme_changed_email" do
    let(:school_cohort) { create :school_cohort }
    let!(:induction_coordinator) { create(:user, :induction_coordinator, schools: [school_cohort.school]) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile: ect_profile, start_date: 6.months.ago, mentor_profile:) }

    let(:training_materials_email) do
      MentorMailer.with(
        mentor_email: mentor_profile.user.email,
        mentor_name: mentor_profile.user.full_name,
        school_name: induction_record.school.name,
        ect_name: induction_record.participant_profile.user.full_name,
        lead_provider_name: induction_record.lead_provider.name,
        sit_name: induction_record.school.induction_tutor.full_name,
      ).training_materials.deliver_now
    end

    it "renders the right headers" do
      expect(training_materials_email.to).to eq([mentor_profile.user.email])
      expect(training_materials_email.from).to eq(["mail@example.com"])
    end
  end
end
