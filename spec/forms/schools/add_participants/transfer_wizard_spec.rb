# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::AddParticipants::TransferWizard, type: :model do
  let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let(:next_cohort) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
  let(:data_store) do
    FormData::AddParticipantStore.new(session: { any_key: { trn:,
                                                            confirmed_trn: trn,
                                                            transfer_confirmed: "yes" } },
                                      form_key: :any_key)
  end
  let(:from_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_and_partnered_in(cohort:)
      .school
  end
  let(:from_school_cohort) { from_school.school_cohorts.first }
  let(:from_induction_programme) { from_school_cohort.default_induction_programme }
  let(:participant_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: from_school_cohort)
                                                .build(training_status:)
                                                .with_induction_record(induction_programme: from_induction_programme,
                                                                       training_status:)
                                                .participant_profile
  end
  let(:trn) { participant_profile.trn }
  let(:training_status) { :active }
  let(:user) { create(:user) }
  let(:to_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_and_partnered_in(cohort:)
      .chosen_fip_and_partnered_in(cohort: next_cohort)
      .school
  end

  subject(:form) { described_class.new(current_step: "joining_date", data_store:, current_user: user, school: to_school) }

  describe "#needs_to_confirm_programme?" do
    context "when the participant was withdrawn" do
      let(:training_status) { :withdrawn }

      it "returns false" do
        expect(form.needs_to_confirm_programme?).to be_falsey
      end
    end

    context "when the participant has no current providers" do
      before do
        from_induction_programme.update!(partnership: nil)
      end

      it "returns false" do
        expect(form.needs_to_confirm_programme?).to be_falsey
      end
    end

    context "when the target school has no default providers for the participant cohort and its latest cohort" do
      before do
        to_school.school_cohorts.each { |sc| sc.update!(default_induction_programme: nil) }
      end

      it "returns false" do
        expect(form.needs_to_confirm_programme?).to be_falsey
      end
    end

    context "when the target school has the same providers for the participant and current cohorts" do
      let(:scenario) { NewSeeds::Scenarios::Schools::School.new.build }
      let(:to_school) { scenario.school }

      let(:participant_cohort_partnership) do
        FactoryBot.create(:seed_partnership,
                          cohort:,
                          school: to_school,
                          lead_provider: from_induction_programme.lead_provider,
                          delivery_partner: from_induction_programme.delivery_partner)
      end

      let(:current_cohort_partnership) do
        FactoryBot.create(:seed_partnership,
                          cohort: next_cohort,
                          school: to_school,
                          lead_provider: from_induction_programme.lead_provider,
                          delivery_partner: from_induction_programme.delivery_partner)
      end

      before do
        scenario.chosen_fip_and_partnered_in(cohort:, partnership: participant_cohort_partnership)
                .chosen_fip_and_partnered_in(cohort: next_cohort, partnership: current_cohort_partnership)
      end

      it "returns false" do
        expect(form.needs_to_confirm_programme?).to be_falsey
      end
    end

    context "when the target school has a different provider for the participant cohort" do
      let(:to_school) do
        NewSeeds::Scenarios::Schools::School
          .new
          .build
          .chosen_fip_and_partnered_in(cohort:)
          .school
      end

      it "returns true" do
        expect(form.needs_to_confirm_programme?).to be_truthy
      end
    end

    context "when the target school has a different provider for the current cohort" do
      before do
        to_school.school_cohorts.for_year(cohort.start_year).first.update!(default_induction_programme: nil)
      end

      it "returns true" do
        expect(form.needs_to_confirm_programme?).to be_truthy
      end
    end
  end

  describe "#needs_to_choose_school_programme?" do
    context "when the participant will continue with their current programme" do
      before do
        allow(form).to receive(:continue_current_programme?).and_return(true)
      end

      it "returns false" do
        expect(form.needs_to_choose_school_programme?).to be_falsey
      end
    end

    context "when the target school has no default providers for the participant cohort and its latest cohort" do
      before do
        to_school.school_cohorts.each { |sc| sc.update!(default_induction_programme: nil) }
      end

      it "returns false" do
        expect(form.needs_to_choose_school_programme?).to be_falsey
      end
    end

    context "when the target school has default providers for the participant cohort" do
      let(:to_school) do
        NewSeeds::Scenarios::Schools::School
          .new
          .build
          .chosen_fip_and_partnered_in(cohort:)
          .school
      end

      it "returns true" do
        expect(form.needs_to_choose_school_programme?).to be_truthy
      end
    end

    context "when the target school has default providers for the current cohort" do
      before do
        to_school.school_cohorts.for_year(cohort.start_year).first.update!(default_induction_programme: nil)
      end

      it "returns true" do
        expect(form.needs_to_choose_school_programme?).to be_truthy
      end
    end
  end
end
