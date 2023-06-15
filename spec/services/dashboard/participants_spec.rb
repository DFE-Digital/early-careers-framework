# frozen_string_literal: true

RSpec.describe Dashboard::Participants, :with_default_schedules do
  let!(:transfer_1) do
    NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider.new
  end
  let!(:ect_1_induction_record_2) { transfer_1.build }
  let!(:participant_profile) { transfer_1.participant_profile }
  let!(:ect_1_induction_record_1) { participant_profile.induction_records.order(:created_at).first }
  let!(:ect_1_induction_record_3) do
    Induction::TransferToSchoolsProgramme.call(participant_profile:,
                                               induction_programme: ect_1_induction_record_1.induction_programme)
  end
  let!(:withdrawn_induction_record) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: ect_1_induction_record_1.school_cohort)
      .build
      .add_induction_record(induction_programme: transfer_1.induction_programme_from, induction_status: :withdrawn)
  end
  let!(:deferred_induction_record) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: ect_1_induction_record_1.school_cohort)
      .build
      .add_induction_record(induction_programme: transfer_1.induction_programme_from, training_status: :deferred)
  end
  let!(:not_mentoring_induction_record) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: ect_1_induction_record_1.school_cohort)
      .build
      .add_induction_record(induction_programme: transfer_1.induction_programme_from)
  end
  let(:school_1) { ect_1_induction_record_1.school }
  let(:user) { double(User, admin?: true) }

  describe "#ects" do
    subject do
      described_class.new(school: school_1, user:).ects.map(&:induction_record)
    end

    it "returns a unique entry per ect currently active or transferring in or transferred from the school" do
      expect(subject).to contain_exactly(ect_1_induction_record_3)
    end
  end

  describe "#not_mentoring_or_being_mentored" do
    subject do
      described_class.new(school: school_1, user:).not_mentoring_or_being_mentored.map(&:induction_record)
    end

    it "returns a unique entry per ect mentor not mentoring or ects not training" do
      expect(subject).to contain_exactly(deferred_induction_record, not_mentoring_induction_record)
    end
  end
end
