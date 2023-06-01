# frozen_string_literal: true

RSpec.describe Schools::Cohorts::SetupWizard, type: :model do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:current_step) { :email }
  let(:data_store) { instance_double(FormData::CohortSetupStore) }
  let(:school) { create(:seed_school, :with_induction_coordinator) }
  let(:school_cohort) { create(:seed_school_cohort, :fip, cohort:, school:) }
  let(:sit_user) { school.induction_coordinators.first }
  let(:submitted_params) { {} }

  subject(:wizard) { described_class.new(current_step:, data_store:, current_user: sit_user, school:, submitted_params:) }

  before do
    allow(data_store).to receive(:store).and_return({ something: "is here" })
    allow(data_store).to receive(:current_user).and_return(sit_user)
    allow(data_store).to receive(:school_id).and_return(school.slug)
    allow(data_store).to receive(:set)
  end

