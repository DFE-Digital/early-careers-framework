# frozen_string_literal: true

RSpec.describe Admin::Participants::AuditTrailComponent, :with_support_for_ect_examples, type: :component do
  let(:console_user_name) { "Aardvark" }

  # just to make sure that if we turned it on we don't affect other spec tests
  after { PaperTrail.enabled = false }

  let(:audited_thing) { Participants::HistoryBuilder.from_participant_profile(fip_ect_only).events }
  let(:component) { described_class.new audited_thing: }
  subject(:rendered_result) { render_inline(component).text }

  describe "without paper_trail enabled" do
    it "has the correct attributes listed when a FIP ECT is created" do
      travel_to(Time.zone.now - 1.minute) { fip_ect_only }

      expect(subject).to include("Create User ##{fip_ect_only.user.id}")
      expect(subject).to include("Sign in count0")
      expect(subject).to include("Full name#{fip_ect_only.user.full_name}")
      expect(subject).to include("Email#{fip_ect_only.user.email}")

      expect(subject).to include("Create Teacher Profile ##{fip_ect_only.teacher_profile.id}")
      expect(subject).to include("Trn#{fip_ect_only.teacher_profile.trn}")
      expect(subject).to include("School#{fip_ect_only.teacher_profile.school.name}")

      expect(subject).to include("Create ECT ##{fip_ect_only.id}")
      expect(subject).to include("Participant identity#{fip_ect_only.participant_identity.id}")
      expect(subject).to include("Training status#{fip_ect_only.training_status}")
      expect(subject).to include("Status#{fip_ect_only.training_status}")
      expect(subject).to include("Teacher profile#{fip_ect_only.teacher_profile.id}")
      expect(subject).to include("School cohort#{fip_ect_only.school_cohort.id}")
      expect(subject).to include("TypeParticipantProfile::ECT")

      expect(subject).to include("Create Participant Identity ##{fip_ect_only.participant_identity.id}")
      expect(subject).to include("Email#{fip_ect_only.participant_identity.email}")
    end
  end

  describe "with paper_trail enabled" do
    before do
      PaperTrail.enabled = true
    end

    it "has the correct attributes listed when a FIP ECT is created" do
      travel_to(Time.zone.now - 1.minute) { fip_ect_only }

      expect(subject).to include "Create User ##{fip_ect_only.user.id}"
      expect(subject).to include "Full name#{fip_ect_only.user.full_name}"
      expect(subject).to include "Email#{fip_ect_only.user.email}"

      expect(subject).to include "Create Teacher Profile ##{fip_ect_only.teacher_profile.id}"
      expect(subject).to include "Trn#{fip_ect_only.teacher_profile.trn}"
      expect(subject).to include "School#{fip_ect_only.teacher_profile.school.name}"

      expect(subject).to include "Update Teacher Profile ##{fip_ect_only.teacher_profile.id}"
      expect(subject).to include "User#{fip_ect_only.teacher_profile.user.id}"

      expect(subject).to include "Create ECT ##{fip_ect_only.id}"
      expect(subject).to include "Participant identity#{fip_ect_only.participant_identity.id}"
      expect(subject).to include "Teacher profile#{fip_ect_only.teacher_profile.id}"
      expect(subject).to include "School cohort#{fip_ect_only.school_cohort.id}"
      expect(subject).to include "TypeParticipantProfile::ECT"

      expect(subject).to include "Create Participant Identity ##{fip_ect_only.participant_identity.id}"
      expect(subject).to include "Email#{fip_ect_only.participant_identity.email}"

      expect(subject).to include "Create Induction Record ##{fip_ect_only.induction_records.first.id}"
      expect(subject).to include "Participant profile#{fip_ect_only.id}"
      expect(subject).to include "Preferred identity#{fip_ect_only.induction_records.first.preferred_identity.id}"
    end

    it "has the correct lead provider induction programme when a FIP ECT is created" do
      travel_to(Time.zone.now - 1.minute) { fip_ect_only }

      expect(subject).to include "Teach First TF Delivery Partner (2022/23)"
    end

    it "shows a name change" do
      travel_to(Time.zone.now - 1.minute) { fip_ect_only }

      new_name = "Martin Luther"
      original_name = fip_ect_only.user.full_name

      fip_ect_only.user.update! full_name: new_name

      expect(subject).to include "Create User ##{fip_ect_only.user.id}"
      expect(subject).to include "Full name#{original_name}"

      expect(subject).to include "Update User ##{fip_ect_only.user.id}"
      expect(subject).to include "Full name#{new_name}"
    end

    it "shows a trn change" do
      travel_to(Time.zone.now - 1.minute) { fip_ect_only }

      new_trn = "0123456"
      original_trn = fip_ect_only.teacher_profile.trn

      fip_ect_only.user.teacher_profile.update! trn: new_trn

      expect(subject).to include "Create Teacher Profile ##{fip_ect_only.teacher_profile.id}"
      expect(subject).to include "Trn#{original_trn}"

      expect(subject).to include "Update Teacher Profile ##{fip_ect_only.teacher_profile.id}"
      expect(subject).to include "Trn#{new_trn}"
    end

    it "shows a Mentor change" do
      travel_to(Time.zone.now - 1.minute) { fip_ect_only }

      Induction::ChangeMentor.call induction_record: fip_ect_only.induction_records.latest,
                                   mentor_profile: fip_mentor_only

      expect(subject).to include "Update ECT ##{fip_ect_only.id}"
      expect(subject).to include "Mentor profile#{fip_mentor_only.id}"
    end

    it "handles whodunnit entries that are names rather than IDs" do
      travel_to(Time.zone.now - 1.minute) do
        fip_ect_only

        fip_ect_only.versions.each { |version| version.update!(whodunnit: console_user_name) }
      end

      expect(subject).to include "#{console_user_name} (Unknown user)"
    end

    it "handles whodunnit entries that are a user of a type" do
      admin_profile = FactoryBot.create(:seed_admin_profile, :with_user)

      travel_to(Time.zone.now - 1.minute) do
        fip_ect_only

        fip_ect_only.versions.each { |version| version.update!(whodunnit: admin_profile.user.id) }
      end

      expect(subject).to include "#{admin_profile.user.email} (Support user)"
    end
  end
end
