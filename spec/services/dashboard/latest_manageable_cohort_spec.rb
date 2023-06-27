# frozen_string_literal: true

RSpec.describe Dashboard::LatestManageableCohort do
  describe "#call" do
    let(:school) { create(:seed_school) }

    subject do
      described_class.call(school)
    end

    context "when the school is included in the pilot" do
      before do
        FeatureFlag.activate(:cohortless_dashboard, for: school)
      end

      it "returns the active registration cohort" do
        expect(subject).to eq(Cohort.active_registration_cohort)
      end
    end

    context "when the school is not included in the pilot" do
      before do
        FeatureFlag.deactivate(:cohortless_dashboard)
      end

      it "returns the current cohort" do
        expect(subject).to eq(Cohort.current)
      end
    end
  end
end
