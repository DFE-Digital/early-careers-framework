# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohort, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:school) }
  end

  it {
    is_expected.to define_enum_for(:induction_programme_choice).with_values(
      full_induction_programme: "full_induction_programme",
      core_induction_programme: "core_induction_programme",
      design_our_own: "design_our_own",
      not_yet_known: "not_yet_known",
    ).backed_by_column_of_type(:string)
  }

  it { is_expected.to respond_to(:training_provider_status) }
  it { is_expected.to respond_to(:add_participants_status) }
  it { is_expected.to respond_to(:choose_training_materials_status) }
  it { is_expected.to respond_to(:status) }

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
    end
  end
end
