require "rails_helper"

RSpec.describe Finance::Statements::MarkAsPayable do
  include_context "with default schedules"

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:ineligible_for_funding) { create(:ecf_participant_profile, :ect_participant_profile, schedule: Finance::Schedule::ECF.default) }
  let(:school) { create(:school) }
  let(:submitted_declaration) {}
  let(:partnership) do
    create(
      :partnership,
      school: ect_profile.school,
      lead_provider: cpd_lead_provider.lead_provider,
      cohort: ect_profile.cohort,
      delivery_partner: create(:delivery_partner),
    )
  end
  let(:induction_programme) { create(:induction_programme, :fip, partnership: partnership) }

  before do
    create(
      :partnership,
      school: ect_profile.school,
      lead_provider: cpd_lead_provider.lead_provider,
      cohort: ect_profile.cohort,
      delivery_partner: create(:delivery_partner),
    )
    Induction::Enrol.call(participant_profile: ineligible_for_funding, induction_programme: induction_programme)
  end

  it "transitions eligible declarations to payable" do
  end
end
