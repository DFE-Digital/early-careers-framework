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

  it { is_expected.to respond_to(:number_of_participants_status) }
  it { is_expected.to respond_to(:training_provider_status) }
  it { is_expected.to respond_to(:accept_legal_status) }
  it { is_expected.to respond_to(:add_participants_status) }
  it { is_expected.to respond_to(:choose_training_materials_status) }
  it { is_expected.to respond_to(:number_of_participants_status) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:school_chose_cip?) }
end
