# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::Resume::Mentor do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:profile) { create(:mentor_participant_profile, training_status: "deferred") }
  let(:user) { profile.user }
  let(:school) { profile.school_cohort.school }
  let(:cohort) { profile.school_cohort.cohort }
  let!(:partnership) do
    create(
      :partnership,
      school: school,
      lead_provider: lead_provider,
      cohort: cohort,
    )
  end

  subject do
    described_class.new(
      params: {
        participant_id: user.id,
        course_identifier: "ecf-mentor",
        cpd_lead_provider: cpd_lead_provider,
      },
    )
  end

  describe "#call" do
    it "updates profile training_status to active" do
      expect { subject.call }.to change { profile.reload.training_status }.from("deferred").to("active")
    end

    it "creates a ParticipantProfileState" do
      expect { subject.call }.to change { ParticipantProfileState.count }.by(1)
    end

    context "when already active" do
      before do
        described_class.new(
          params: {
            participant_id: user.id,
            course_identifier: "ecf-mentor",
            cpd_lead_provider: cpd_lead_provider,
          },
        ).call # must be different instance from subject
      end

      it "returns an error and does not update training_status" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid).and not_change { profile.reload.training_status }
      end
    end

    context "when status is withdrawn" do
      before do
        ParticipantProfileState.create!(participant_profile: profile, state: "withdrawn")
        profile.update!(status: "withdrawn")
      end

      xit "returns an error and does not update training_status" do
        # TODO: there is a gap and bug here
        # it should return a useful error
        # but throws an error as we scope to active profiles only and therefore never find the record
      end
    end
  end
end
