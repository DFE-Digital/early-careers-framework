# frozen_string_literal: true

RSpec.describe Oneoffs::FixInductionRecordSchoolMismatches do
  before { allow(Rails.logger).to receive(:info) }

  let(:instance) { described_class.new }

  describe "#perform_change" do
    let(:dry_run) { false }
    let(:cohort) { create(:cohort, :current) }
    let(:lead_provider) { create(:lead_provider) }
    let(:delivery_partner) { create(:delivery_partner) }

    subject(:perform_change) { instance.perform_change(dry_run:) }

    it "updates school_cohort school when partnership is open and cohort is closed" do
      partnership_school = create(:school, :open)
      cohort_school = create(:school, :closed)
      school_cohort = create(:school_cohort, cohort:, school: cohort_school)
      partnership = create(:partnership, cohort:, school: partnership_school, lead_provider:, delivery_partner:)
      induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
      create(:induction_record, induction_programme:)

      expect(school_cohort.school_id).not_to eq(partnership_school.id)

      perform_change

      expect(school_cohort.reload.school_id).to eq(partnership_school.id)
    end

    it "relinks induction_programme to an existing school_cohort when present" do
      partnership_school = create(:school, :open)
      cohort_school = create(:school, :closed)
      existing_school_cohort = create(:school_cohort, cohort:, school: partnership_school)
      school_cohort = create(:school_cohort, cohort:, school: cohort_school)
      partnership = create(:partnership, cohort:, school: partnership_school, lead_provider:, delivery_partner:)
      induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
      create(:induction_record, induction_programme:)

      expect(induction_programme.school_cohort_id).not_to eq(existing_school_cohort.id)

      perform_change

      expect(induction_programme.reload.school_cohort_id).to eq(existing_school_cohort.id)
    end

    it "relinks induction_programme to an existing partnership when present" do
      partnership_school = create(:school, :open)
      cohort_school = create(:school, :open)
      school_cohort = create(:school_cohort, cohort:, school: cohort_school)
      partnership = create(:partnership, cohort:, school: partnership_school, lead_provider:, delivery_partner:)
      existing_partnership = create(:partnership, cohort:, school: cohort_school, lead_provider:, delivery_partner:)
      induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
      create(:induction_record, induction_programme:)

      expect(induction_programme.partnership_id).not_to eq(existing_partnership.id)

      perform_change

      expect(induction_programme.reload.partnership_id).to eq(existing_partnership.id)
    end

    it "updates partnership school when both schools are open and no existing partnership exists" do
      partnership_school = create(:school, :open)
      cohort_school = create(:school, :open)
      school_cohort = create(:school_cohort, cohort:, school: cohort_school)
      partnership = create(:partnership, cohort:, school: partnership_school, lead_provider:, delivery_partner:)
      induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
      create(:induction_record, induction_programme:)

      expect(partnership.school_id).not_to eq(cohort_school.id)

      perform_change

      expect(partnership.reload.school_id).to eq(cohort_school.id)
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not persist changes" do
        partnership_school = create(:school, :open)
        cohort_school = create(:school, :closed)
        school_cohort = create(:school_cohort, cohort:, school: cohort_school)
        partnership = create(:partnership, cohort:, school: partnership_school, lead_provider:, delivery_partner:)
        induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
        create(:induction_record, induction_programme:)

        expect { perform_change }.not_to change { school_cohort.reload.school_id }
      end
    end
  end
end
