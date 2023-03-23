# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.describe SchoolCohortSerializer do
        describe "serialization" do
          let(:school_cohort) { create(:school_cohort) }
          let(:school) { school_cohort.school }
          let(:cohort) { school_cohort.cohort }

          subject { described_class.new(school_cohort) }

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
            let(:school_cohort) { create(:school_cohort, lead_provider:) }

            it "returns in_partnership as true" do
              expect(subject.serializable_hash[:data][:attributes][:in_partnership]).to be true
            end
          end

          context "when the school is not in partnership" do
            it "returns in_partnership as false" do
              expect(subject.serializable_hash[:data][:attributes][:in_partnership]).to be false
            end
          end

          it "returns the school cohort induction_programme_choice" do
            expect(subject.serializable_hash[:data][:attributes][:induction_programme_choice]).to eq(school_cohort.induction_programme_choice)
          end

          it "returns the school updated_at" do
            expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(school.updated_at)
          end
        end
      end
    end
  end
end
