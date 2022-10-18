# frozen_string_literal: true

RSpec.describe Induction::ChangePartnership do
  describe "#call" do
    let(:school_cohort) { create(:school_cohort) }
    let(:lead_provider) { create(:lead_provider, name: "Super provider") }
    let(:lead_provider_2) { create(:lead_provider, name: "Mega provider") }
    let(:partnership) { create(:partnership, :challenged, school: school_cohort.school, cohort: school_cohort.cohort, lead_provider:) }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:, partnership:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:new_partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort, lead_provider: lead_provider_2) }

    subject(:service) { described_class }

    before do
      Induction::Enrol.call(induction_programme:,
                            participant_profile: mentor_profile,
                            start_date: 6.months.ago)

      Induction::Enrol.call(induction_programme:,
                            participant_profile: ect_profile,
                            start_date: 6.months.ago,
                            mentor_profile:)

      school_cohort.update!(default_induction_programme: induction_programme)
    end

    it "adds a new induction programme" do
      expect {
        service.call(school_cohort:,
                     partnership: new_partnership)
      }.to change { InductionProgramme.count }.by 1
    end

    it "sets the new programme as the default for the school cohort" do
      service.call(school_cohort:,
                   partnership: new_partnership)

      expect(school_cohort.default_induction_programme).to eq school_cohort.induction_programmes.order(created_at: :desc).first
    end

    it "sets the partnership on the new programme" do
      service.call(school_cohort:,
                   partnership: new_partnership)

      expect(school_cohort.default_induction_programme.partnership).to eq new_partnership
    end

    it "migrates the participants to the new programme" do
      service.call(school_cohort:,
                   partnership: new_partnership)

      expect(school_cohort.default_induction_programme.induction_records).to match_array [ect_profile.current_induction_record, mentor_profile.current_induction_record]
    end

    context "when the default programme does not have a partnership" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort:, partnership: nil) }

      it "does not create a new induction_programme" do
        expect {
          service.call(school_cohort:,
                       partnership: new_partnership)
        }.not_to change { InductionProgramme.count }
      end

      it "sets the partnership on the existing programme" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(induction_programme.partnership).to eq new_partnership
      end

      it "does not change the default induction programme for the school cohort" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(school_cohort.default_induction_programme).to eq induction_programme
      end
    end

    context "when the default induction programme is not a FIP" do
      let(:induction_programme) { create(:induction_programme, :cip, school_cohort:) }

      it "creates a new induction_programme" do
        expect {
          service.call(school_cohort:,
                       partnership: new_partnership)
        }.to change { InductionProgramme.count }
      end

      it "sets the partnership on the new programme" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(school_cohort.default_induction_programme.partnership).to eq new_partnership
      end

      it "changes the default induction programme for the school cohort" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(school_cohort.default_induction_programme).to eq school_cohort.induction_programmes.full_induction_programme.first
      end

      it "sets the school cohort choice to FIP" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(school_cohort.reload).to be_full_induction_programme
      end

      it "migrates the participants to the new programme" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(school_cohort.default_induction_programme.induction_records).to match_array [ect_profile.current_induction_record, mentor_profile.current_induction_record]
      end
    end

    context "when the existing partnership has not been challenged" do
      let(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort, lead_provider:) }

      it "does not create a new induction_programme" do
        expect {
          service.call(school_cohort:,
                       partnership: new_partnership)
        }.not_to change { InductionProgramme.count }
      end

      it "does not set the partnership on the existing programme" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(induction_programme.partnership).to eq partnership
      end

      it "does not change the default induction programme for the school cohort" do
        service.call(school_cohort:,
                     partnership: new_partnership)

        expect(school_cohort.default_induction_programme).to eq induction_programme
      end
    end
  end
end
