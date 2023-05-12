# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.describe SchoolSerializer do
        describe "serialization" do
          let(:school) { create(:school) }
          let(:cohort) { create(:cohort) }

          subject { described_class.new(school, params: { cohort: }) }

          it "sets the ID as the school ID" do
            expect(subject.serializable_hash[:data][:id]).to eq(school.id)
          end

          it "sets the type" do
            expect(subject.serializable_hash[:data][:type]).to eq(:school)
          end

          it "returns the school name" do
            expect(subject.serializable_hash[:data][:attributes][:name]).to eq(school.name)
          end

          it "returns the school URN" do
            expect(subject.serializable_hash[:data][:attributes][:urn]).to eq(school.urn)
          end

          it "returns the cohort to the cohort start year" do
            expect(subject.serializable_hash[:data][:attributes][:cohort]).to eq(cohort.start_year.to_s)
          end

          context "when the school is in partnership" do
            let(:lead_provider) { create(:lead_provider) }
            let!(:school_cohort) { create(:school_cohort, lead_provider:, school:, cohort:) }

            it "returns in_partnership as true" do
              expect(subject.serializable_hash[:data][:attributes][:in_partnership]).to be true
            end
          end

          context "when the school is not in partnership" do
            it "returns in_partnership as false" do
              expect(subject.serializable_hash[:data][:attributes][:in_partnership]).to be false
            end
          end

          context "when the school is already in the cohort" do
            let!(:school_cohort) { create(:school_cohort, school:, cohort:) }
            it "returns the school cohort induction_programme_choice" do
              expect(subject.serializable_hash[:data][:attributes][:induction_programme_choice]).to eq(school_cohort.induction_programme_choice)
            end
          end

          context "when school is not yet in the cohort" do
            it "returns the an unknown induction programme choice" do
              expect(subject.serializable_hash[:data][:attributes][:induction_programme_choice]).to eq("not_yet_known")
            end
          end

          context "when the school is updated last" do
            let(:school_cohort) { create(:school_cohort, school:, cohort:) }
            before do
              school_cohort
              Timecop.travel(1.day.from_now) { school.touch }
            end

            it "returns the school updated_at" do
              expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(school.updated_at.rfc3339)
            end
          end

          context "when the school cohort is updated last" do
            let(:school_cohort) { create(:school_cohort, school:, cohort:) }

            before do
              school_cohort
              Timecop.travel(1.day.from_now) { school_cohort.touch }
            end

            it "returns the school cohort updated_at" do
              expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(school_cohort.updated_at.rfc3339)
            end
          end

          context "when there is no school cohort" do
            it "returns the school updated_at" do
              expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(school.updated_at.rfc3339)
            end
          end
        end
      end
    end
  end
end
