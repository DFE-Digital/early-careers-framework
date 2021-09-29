# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::CipInfo, type: :view_component do
  let(:school_cohort) { FactoryBot.create :school_cohort, :cip, core_induction_programme: programme }
  let(:programme) { FactoryBot.create :core_induction_programme }

  component { described_class.new school_cohort: school_cohort }

  it { is_expected.to have_content "Use the DfE accredited materials" }
  it { is_expected.to have_content programme.name }

  context "when no programme is selected" do
    let(:programme) { nil }

    it { is_expected.to render }
  end
end
