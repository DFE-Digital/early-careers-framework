# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionProgramme, type: :model do
  subject(:induction_programme) { create(:induction_programme, :cip) }

  describe "changes" do
    let(:induction_records) { create_list(:induction_record, 3, induction_programme: induction_programme) }

    before do
      induction_records.each do |induction_record|
        induction_record.update!(created_at: 2.weeks.ago, updated_at: 1.week.ago)
      end
      induction_programme.current_induction_records.reload
    end

    it "updates the updated_at on the induction_record" do
      induction_programme.touch
      induction_records.each do |induction_record|
        expect(induction_record.reload.updated_at).to be_within(1.second).of induction_programme.updated_at
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:school_cohort) }
    it { is_expected.to belong_to(:partnership).optional }
    it { is_expected.to belong_to(:core_induction_programme).optional }

    it { is_expected.to have_many(:induction_records) }
    it { is_expected.to have_many(:active_induction_records) }
    it { is_expected.to have_many(:transferring_in_induction_records) }
    it { is_expected.to have_many(:transferring_out_induction_records) }
    it { is_expected.to have_many(:participant_profiles).through(:active_induction_records) }
    it { is_expected.to have_many(:current_induction_records) }
    it { is_expected.to have_many(:current_participant_profiles).through(:current_induction_records).source(:participant_profile) }
  end
end
