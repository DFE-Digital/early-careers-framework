# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohort, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:school) }
  end

  it "updates the updated_at on participant profiles and users" do
    freeze_time
    school_cohort = create(:school_cohort)
    profile = create(:participant_profile, :ect, school_cohort: school_cohort, updated_at: 2.weeks.ago)
    user = profile.user
    user.update!(updated_at: 2.weeks.ago)

    school_cohort.touch
    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
    expect(profile.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  it {
    is_expected.to define_enum_for(:induction_programme_choice).with_values(
      full_induction_programme: "full_induction_programme",
      core_induction_programme: "core_induction_programme",
      design_our_own: "design_our_own",
      school_funded_fip: "school_funded_fip",
      no_early_career_teachers: "no_early_career_teachers",
      not_yet_known: "not_yet_known",
    ).backed_by_column_of_type(:string)
  }

  it { is_expected.to respond_to(:training_provider_status) }
  it { is_expected.to respond_to(:add_participants_status) }
  it { is_expected.to respond_to(:choose_training_materials_status) }
  it { is_expected.to respond_to(:status) }

  describe ".for_year" do
    let(:school) { create(:school) }
    let(:cohort) { create(:cohort, start_year: 2020) }
    subject(:school_cohort) { create(:school_cohort, school: school, cohort: cohort) }

    before do
      school_cohort
    end

    it "returns the school cohort for the given year" do
      expect(school.school_cohorts.for_year(2020).first).to eq school_cohort
    end
  end

  describe "#status" do
    context "when core induction programme is selected" do
      subject(:school_cohort) { create(:school_cohort, induction_programme_choice: "core_induction_programme") }
      it "returns the result of #cip_status" do
        expect(school_cohort.status).to eq school_cohort.send(:cip_status)
      end
    end

    context "when full induction programme is selected" do
      subject(:school_cohort) { create(:school_cohort, induction_programme_choice: "full_induction_programme") }
      it "returns the result of #fip_status" do
        expect(school_cohort.status).to eq school_cohort.send(:fip_status)
      end
    end

    context "when a choice hasn't been made" do
      subject(:school_cohort) { create(:school_cohort, induction_programme_choice: "not_yet_known") }
      it "returns 'To do'" do
        expect(school_cohort.status).to eq "To do"
      end
    end

    context "when design our own programme is selected" do
      subject(:school_cohort) { create(:school_cohort, induction_programme_choice: "design_our_own") }
      it "returns nil" do
        expect(school_cohort.status).to be_nil
      end
    end

    context "when no early career teachers is selected" do
      subject(:school_cohort) { create(:school_cohort, induction_programme_choice: "no_early_career_teachers") }
      it "returns nil" do
        expect(school_cohort.status).to be_nil
      end
    end
  end

  describe "#training_provider_status" do
    subject(:school_cohort) { create(:school_cohort) }

    it "returns 'To do' by default" do
      expect(subject.training_provider_status).to eq "To do"
    end

    context "when school is in a partnership" do
      let(:lead_provider) { create(:lead_provider) }
      let(:delivery_partner) { create(:delivery_partner) }

      before do
        Partnership.create!(
          cohort: school_cohort.cohort,
          lead_provider: lead_provider,
          school: school_cohort.school,
          delivery_partner: delivery_partner,
        )
      end

      it "returns 'Done' by default" do
        expect(subject.training_provider_status).to eq "Done"
      end

      context "when the partnership has been challenged" do
        before do
          Partnership.find_by(school: school_cohort.school).update!(challenged_at: Time.zone.now, challenge_reason: "mistake")
        end

        it "returns 'To do'" do
          expect(subject.training_provider_status).to eq "To do"
        end
      end
    end
  end

  describe "#lead_provider" do
    subject(:school_cohort) { create(:school_cohort) }

    context "when the school has chosen FIP for the cohort" do
      let(:lead_provider) { create(:lead_provider) }
      let(:delivery_partner) { create(:delivery_partner) }

      before do
        Partnership.create!(
          cohort: school_cohort.cohort,
          lead_provider: lead_provider,
          school: school_cohort.school,
          delivery_partner: delivery_partner,
        )
      end

      it "returns the lead provider" do
        expect(school_cohort.lead_provider).to eq(lead_provider)
      end
    end

    context "when the school has chosen CIP for the cohort" do
      let(:cip) { create(:core_induction_programme) }

      before do
        school_cohort.update!(induction_programme_choice: "core_induction_programme",
                              core_induction_programme: cip)
      end

      it "returns nil" do
        expect(school_cohort.lead_provider).to be_nil
      end
    end
  end

  describe "#delivery_partner" do
    subject(:school_cohort) { create(:school_cohort) }

    context "when the school has chosen FIP for the cohort" do
      let(:lead_provider) { create(:lead_provider) }
      let(:delivery_partner) { create(:delivery_partner) }

      before do
        Partnership.create!(
          cohort: school_cohort.cohort,
          lead_provider: lead_provider,
          school: school_cohort.school,
          delivery_partner: delivery_partner,
        )
      end

      it "returns the delivery partner" do
        expect(school_cohort.delivery_partner).to eq(delivery_partner)
      end
    end

    context "when the school has chosen CIP for the cohort" do
      let(:cip) { create(:core_induction_programme) }

      before do
        school_cohort.update!(induction_programme_choice: "core_induction_programme",
                              core_induction_programme: cip)
      end

      it "returns nil" do
        expect(school_cohort.delivery_partner).to be_nil
      end
    end
  end
end
