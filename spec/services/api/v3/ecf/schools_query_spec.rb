# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::SchoolsQuery do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let!(:school_cohort) { create(:school_cohort, cohort:) }
  let(:school) { school_cohort.school }

  let(:params) { {} }

  subject { described_class.new(params:) }

  describe "#schools" do
    let(:another_cohort) { Cohort.next || create(:cohort, :next) }
    let!(:another_school_cohort) { create(:school_cohort, cohort: another_cohort) }
    let!(:another_school) { another_school_cohort.school }

    it "returns all schools" do
      expect(subject.schools).to match_array([school_cohort, another_school_cohort])
    end

    describe "cohort filter" do
      context "with correct value" do
        let(:params) { { filter: { cohort: cohort.display_name } } }

        it "returns all schools for the specific cohort" do
          expect(subject.schools).to match_array([school_cohort])
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { cohort: "2017" } } }

        it "returns no schools" do
          expect(subject.schools).to be_empty
        end
      end
    end

    describe "school urn filter" do
      context "with correct value" do
        let(:params) { { filter: { urn: another_school.urn } } }

        it "returns all schools for the specific urn" do
          expect(subject.schools).to match_array([another_school_cohort])
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { urn: "abc" } } }

        it "returns no schools" do
          expect(subject.schools).to be_empty
        end
      end
    end
  end
end
