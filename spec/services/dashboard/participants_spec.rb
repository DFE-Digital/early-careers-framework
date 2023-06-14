# frozen_string_literal: true

RSpec.describe Dashboard::Participants, :with_default_schedules do
  describe "#ects" do
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
    let!(:ect_2_induction_record) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort: ect_1_induction_record_1.school_cohort)
        .build
        .add_induction_record(induction_programme: transfer_1.induction_programme_from, induction_status: :withdrawn)
    end
    let(:school_1) { ect_1_induction_record_1.school }
    let(:user) { double(User, admin?: true) }

    subject do
      described_class.new(school: school_1, user:).ects
    end

    it "returns a unique entry per ect currently active or transferring in or transferred from the school" do
      expect(subject).not_to include(ect_1_induction_record_1)
      expect(subject).to include(ect_1_induction_record_3)
      expect(subject).not_to include(ect_2_induction_record)
    end
  end
end
