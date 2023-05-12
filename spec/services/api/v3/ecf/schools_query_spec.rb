# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::SchoolsQuery do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:params) { {} }

  subject { described_class.new(params:) }

  describe "#schools" do
    let(:another_cohort) { Cohort.next || create(:cohort, :next) }

    context "with no cohort filter" do
      let!(:eligible_school) { create(:school, :eligible) }

      it "returns no schools" do
        expect(subject.schools).to be_empty
      end

      context "with any other filter" do
        let(:params) { { filter: { urn: eligible_school.urn } } }

        it "returns no schools" do
          expect(subject.schools).to be_empty
        end
      end
    end

    context "with cohort filter" do
      let(:params) { { filter: { cohort: cohort.display_name } } }

      context "with eligible school" do
        let!(:eligible_school) { create(:school, :eligible) }
        let!(:ineligible_school) { create(:school, :closed) }

        it "returns all eligible schools for the specific cohort" do
          expect(subject.schools).to match_array([eligible_school])
        end
      end

      context "with eligible cip only school" do
        let!(:eligible_cip_only_school) { create(:school, :eligible, :cip_only) }

        it "returns all eligible schools for the specific cohort" do
          expect(subject.schools).to match_array([eligible_cip_only_school])
        end
      end

      context "with ineligible school which was eligible in the current cohort" do
        let(:ineligible_school) { create(:school, :closed) }
        let!(:partnership) { create(:partnership, school: ineligible_school, cohort:) }

        let(:another_ineligible_school) { create(:school, :closed) }

        it "returns all schools with partnerships for the specific cohort" do
          expect(subject.schools).to match_array([ineligible_school])
        end
      end

      context "with ineligible school which was eligible in a different cohort" do
        let(:ineligible_school) { create(:school, :closed) }
        let!(:partnership) { create(:partnership, school: ineligible_school, cohort: another_cohort) }

        it "does not return the school" do
          expect(subject.schools).to be_empty
        end
      end

      context "with ineligible challenged school which was eligible in the current cohort" do
        let(:ineligible_school) { create(:school, :closed) }
        let!(:partnership) { create(:partnership, :challenged, school: ineligible_school, cohort:) }

        it "does not return the school" do
          expect(subject.schools).to be_empty
        end
      end

      context "with school urn filter" do
        let!(:eligible_school) { create(:school, :eligible) }

        context "with correct value" do
          let(:params) { { filter: { cohort: another_cohort.display_name, urn: eligible_school.urn } } }

          it "returns all schools for the specific urn" do
            expect(subject.schools).to match_array([eligible_school])
          end
        end

        context "with incorrect value" do
          let(:params) { { filter: { cohort: another_cohort.display_name, urn: "abc" } } }

          it "returns no schools" do
            expect(subject.schools).to be_empty
          end
        end
      end
    end
  end

  describe "#school" do
    let!(:eligible_school) { create(:school, :eligible) }

    context "with no cohort filter" do
      it "raises an exception" do
        expect { subject.school }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "with any other filter" do
        let(:params) { { id: eligible_school.id } }

        it "raises an exception" do
          expect { subject.school }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "with cohort filter" do
      context "with correct value" do
        let(:params) { { id: eligible_school.id, filter: { cohort: cohort.display_name } } }

        it "returns the correct school for the specific cohort" do
          expect(subject.school).to eq(eligible_school)
        end
      end

      context "with incorrect value" do
        let(:params) { { id: "wrong-id", filter: { cohort: cohort.display_name } } }

        it "raises an exception" do
          expect { subject.school }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
