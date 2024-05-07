# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Participants::Mentors::Remove do
  def new_remover
    described_class.new(participant_profile_id: participant_profile.id, school_urn: school.urn)
  end

  subject(:remover) { new_remover }

  let(:school) { participant_profile.school }
  let(:participant_profile) { create(:mentor) }

  before do
    # disable logging
    remover.logger = Logger.new("/dev/null")
  end

  describe "#call" do
    it "removes the mentor from the school" do
      expect { remover.call }.to change { school.school_mentors.reload.count }.from(1).to(0)
    end

    it "marks the participant profile as withdrawn" do
      expect { remover.call }.to change { participant_profile.reload.status }.from("active").to("withdrawn")
    end

    describe "when the participant is not mentoring at the school" do
      before do
        school.school_mentors.destroy_all
      end

      it "raises an error" do
        expect { new_remover.call }.to raise_error("ParticipantProfile is not a mentor at this school")
      end
    end

    describe "when removing the mentor from the school fails" do
      before do
        allow(Mentors::RemoveFromSchool).to receive(:call).and_raise(StandardError)
      end

      it "rolls back changes" do
        expect { remover.call }.not_to change { school.school_mentors.reload.count }
        expect { remover.call }.not_to change { participant_profile.reload.status }
      end
    end
  end

  describe "#dry_run" do
    it "rolls back changes" do
      expect { remover.dry_run }.not_to change { school.school_mentors.reload.count }
      expect { remover.dry_run }.not_to change { participant_profile.reload.status }
    end
  end
end
