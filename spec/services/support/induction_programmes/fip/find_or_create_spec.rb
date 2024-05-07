# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::InductionProgrammes::Fip::FindOrCreate do
  subject(:reactivate) { described_class.new(school_urn:, cohort_year:, lead_provider_name:, delivery_partner_name:) }

  let(:school_cohort) { create(:school_cohort, cohort:) }
  let(:school) { school_cohort.school }
  let(:school_urn) { school.urn }
  let(:cohort) { Cohort.current }
  let(:cohort_year) { cohort.start_year }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:delivery_partner_name) { delivery_partner.name }
  let(:lead_provider) { create(:lead_provider) }
  let(:lead_provider_name) { lead_provider.name }

  before do
    # disable logging
    reactivate.logger = Logger.new("/dev/null")
  end

  describe "#call" do
    it "creates a CIP induction programme" do
      expect { reactivate.call }.to change { InductionProgramme.count }.by(1)
    end

    it "creates the correct induction programme" do
      new_induction_programme = reactivate.call
      expect(new_induction_programme.school_cohort).to eq(school_cohort)
      expect(new_induction_programme.training_programme).to eq("full_induction_programme")
      expect(new_induction_programme.cohort.start_year).to eq(cohort_year)
      expect(new_induction_programme.partnership.lead_provider).to eq(lead_provider)
      expect(new_induction_programme.partnership.delivery_partner).to eq(delivery_partner)
    end

    describe "when the induction programme already exists" do
      let!(:school_cohort) do
        create(:school_cohort, :fip, :with_induction_programme, school: create(:school), cohort:, lead_provider:, delivery_partner:)
      end
      let!(:existing_induction_programme) { school_cohort.induction_programmes.first }

      it "does not create a new induction programme" do
        expect { reactivate.call }.to_not change { InductionProgramme.count }
      end

      it "returns the existing induction programme" do
        expect(reactivate.call).to eq(existing_induction_programme)
      end
    end

    describe "validation errors" do
      describe "save raises an error" do
        before do
          allow_any_instance_of(InductionProgramme).to receive(:save!).and_return(false)
        end

        it "rolls back the transaction" do
          expect { reactivate.call }.to_not change { InductionProgramme.count }
        end
      end
    end
  end
end
