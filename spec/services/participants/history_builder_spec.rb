# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::HistoryBuilder, :with_support_for_ect_examples do
  subject { Participants::HistoryBuilder }

  let(:console_user_name) { "Aardvark" }

  after do
    # just to make sure that if we turned it on we don't affect other spec tests
    PaperTrail.enabled = false
  end

  describe "without paper_trail enabled" do
    it "has the correct attributes listed when a FIP ECT is created" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only
      end

      event_list = described_class.from_participant_profile(fip_ect_only).events

      attributes_changed = event_list.map(&:predicate)
      expect(attributes_changed).to match_array %w[
        ParticipantIdentity.email
        ParticipantProfile::ECT.id
        ParticipantProfile::ECT.participant_identity_id
        ParticipantProfile::ECT.profile_duplicity
        ParticipantProfile::ECT.pupil_premium_uplift
        ParticipantProfile::ECT.schedule_id
        ParticipantProfile::ECT.school_cohort_id
        ParticipantProfile::ECT.sparsity_uplift
        ParticipantProfile::ECT.status
        ParticipantProfile::ECT.teacher_profile_id
        ParticipantProfile::ECT.training_status
        ParticipantProfile::ECT.type
        SchoolCohort.cohort_id
        SchoolCohort.id
        SchoolCohort.induction_programme_choice
        SchoolCohort.opt_out_of_updates
        SchoolCohort.school_id
        TeacherProfile.id
        TeacherProfile.school_id
        TeacherProfile.trn
        TeacherProfile.user_id
        User.email
        User.full_name
        User.id
        User.sign_in_count
      ]
    end
  end

  describe "with paper_trail enabled" do
    before do
      PaperTrail.enabled = true
    end

    it "has the correct attributes listed when a FIP ECT is created" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only
      end

      event_list = described_class.from_participant_profile(fip_ect_only).events
      attributes_changed = event_list.map(&:predicate)
      expect(attributes_changed).to match_array %w[
        InductionRecord.id
        InductionRecord.induction_programme_id
        InductionRecord.participant_profile_id
        InductionRecord.preferred_identity_id
        InductionRecord.schedule_id
        ParticipantIdentity.email
        ParticipantProfile::ECT.id
        ParticipantProfile::ECT.participant_identity_id
        ParticipantProfile::ECT.schedule_id
        ParticipantProfile::ECT.school_cohort_id
        ParticipantProfile::ECT.teacher_profile_id
        ParticipantProfile::ECT.type
        SchoolCohort.cohort_id
        SchoolCohort.id
        SchoolCohort.induction_programme_choice
        SchoolCohort.school_id
        TeacherProfile.id
        TeacherProfile.school_id
        TeacherProfile.trn
        TeacherProfile.user_id
        TeacherProfile.user_id
        User.email
        User.full_name
        User.id
      ]
    end

    it "has the correct lead provider induction programme when a FIP ECT is created" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only
      end

      event_list = described_class.from_participant_profile(fip_ect_only).events

      induction_programme_entries = event_list.filter { |ev| ev.predicate == "InductionRecord.induction_programme_id" }
      expect(induction_programme_entries.first.value).to include "full_induction_programme | Teach First"
    end

    it "records a name change at the end" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only
      end

      fip_ect_only.user.update! full_name: "Martin Luthor"

      event_list = described_class.from_participant_profile(fip_ect_only).events

      expect(event_list.last.predicate).to eq "User.full_name"
    end

    it "records a trn change at the end" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only
      end

      fip_ect_only.user.teacher_profile.update! trn: "0123456"

      event_list = described_class.from_participant_profile(fip_ect_only).events

      expect(event_list.last.predicate).to eq "TeacherProfile.trn"
    end

    it "records Mentor change at the end" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only
      end

      Induction::ChangeMentor.call induction_record: fip_ect_only.induction_records.latest,
                                   mentor_profile: fip_mentor_only

      event_list = described_class.from_participant_profile(fip_ect_only).events

      attributes_changed = event_list.map(&:predicate)
      expect(attributes_changed.last(8)).to match_array %w[
        InductionRecord.id
        InductionRecord.induction_programme_id
        InductionRecord.induction_status
        InductionRecord.mentor_profile_id
        InductionRecord.participant_profile_id
        InductionRecord.preferred_identity_id
        InductionRecord.schedule_id
        ParticipantProfile::ECT.mentor_profile_id
      ]
    end

    it "handles whodunnit entries that are names rather than IDs" do
      travel_to(Time.current - 1.minute) do
        fip_ect_only

        fip_ect_only.versions.last.update!(whodunnit: console_user_name)
      end

      event_list = described_class.from_participant_profile(fip_ect_only).events
      reporters = event_list.map(&:reporter)
      expect(reporters).to include console_user_name
    end
  end
end
