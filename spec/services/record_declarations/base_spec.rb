require "rails_helper"

RSpec.describe RecordDeclarations::Base do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:cohort)            { create(:cohort, start_year: Time.zone.today.year) }
  let(:school)            { create(:school) }
  let(:school_cohort)     { create(:school_cohort, school: school, cohort: cohort) }
  let(:declaration_date)  { Time.zone.parse("2021-11-02").rfc3339 }
  let(:declaration_type)  { "started" }
  let(:ect_participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
  let(:params) do
    {
      participant_id: ect_participant_profile.user_id,
      course_identifier: "ecf-induction",
      cpd_lead_provider: cpd_lead_provider,
      declaration_date: declaration_date,
      declaration_type: declaration_type,
    }
  end

  before do
    create(:partnership, lead_provider: cpd_lead_provider.lead_provider, cohort: cohort, school: school)
  end

  describe "#call" do
    subject(:record_declaration) { RecordDeclarations::Started::EarlyCareerTeacher.call(params: params) }

    context "when no duplicate participant exists" do
      context "when the participant is fundable" do
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile: ect_participant_profile) }

        it "transitions the declaration to eligible" do
          expect { record_declaration }
            .to change(ect_participant_profile.reload.participant_declarations.for_lead_provider(cpd_lead_provider).eligible, :count)
            .from(0).to(1)
        end
      end

      context "when the participant is not fundable" do
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile: ect_participant_profile) }

        it "transitions the declaration to submitted" do
          expect { record_declaration }
            .to change(ect_participant_profile.reload.participant_declarations.for_lead_provider(cpd_lead_provider).submitted, :count)
            .from(0).to(1)
        end
      end
    end

    context "when a duplicated participant exist" do
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile: ect_participant_profile) }
      before do
        ect_participant_profile.update!(profile_duplicity: ParticipantProfile::ECF.profile_duplicities[:secondary])
      end

      it "transitions the declaration to ineligible" do
        expect { record_declaration }
          .to change(ect_participant_profile.reload.participant_declarations.for_lead_provider(cpd_lead_provider).ineligible, :count)
          .from(0).to(1)
      end
    end
  end
end
