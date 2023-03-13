# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.describe PartnershipSerializer do
        describe "serialization" do
          let(:cohort) { build(:cohort, start_year: 2021) }
          let(:school) { build(:school, urn: "123456", name: "My first High School") }
          let(:delivery_partner) { partnership.delivery_partner }

          let(:induction_coordinator) { create(:user, full_name: "John Doe", email: "induction_coordinator@example.com") }
          let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school], user: induction_coordinator) }

          let!(:partnership) { create(:partnership, school:, cohort:) }

          subject { described_class.new(partnership) }

          it "sets the partnership id" do
            expect(subject.serializable_hash[:data][:id]).to eq(partnership.id)
          end

          it "sets the type" do
            expect(subject.serializable_hash[:data][:type]).to eq(:"partnership-confirmation")
          end

          it "returns the cohort start year" do
            expect(subject.serializable_hash[:data][:attributes][:cohort]).to eq("2021")
          end

          it "returns the school urn" do
            expect(subject.serializable_hash[:data][:attributes][:urn]).to eq("123456")
          end

          it "returns the school delivery partner id" do
            expect(subject.serializable_hash[:data][:attributes][:delivery_partner_id]).to eq(delivery_partner.id)
          end

          it "returns the school delivery partner name" do
            expect(subject.serializable_hash[:data][:attributes][:delivery_partner_name]).to eq(delivery_partner.name)
          end

          it "returns the induction tutor name" do
            expect(subject.serializable_hash[:data][:attributes][:induction_tutor_name]).to eq("John Doe")
          end

          it "returns the school induction tutor email" do
            expect(subject.serializable_hash[:data][:attributes][:induction_tutor_email]).to eq("induction_coordinator@example.com")
          end

          it "returns the partnership created_at timestamp" do
            expect(subject.serializable_hash[:data][:attributes][:created_at]).to eq(
              partnership.created_at.rfc3339,
            )
          end

          it "returns the partnership updated_at timestamp" do
            expect(subject.serializable_hash[:data][:attributes][:updated_at]).to eq(partnership.updated_at.rfc3339)
          end

          context "when partnership active" do
            it "returns an active status" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
            end

            it "returns no challenged_reason" do
              expect(subject.serializable_hash[:data][:attributes][:challenged_reason]).to be_nil
            end
          end

          context "when partnership challenged" do
            let!(:partnership) { create(:partnership, :challenged, school:, cohort:) }

            it "returns the status" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("challenged")
            end

            it "returns the challenged_reason" do
              expect(subject.serializable_hash[:data][:attributes][:challenged_reason]).to eq("mistake")
            end
          end
        end
      end
    end
  end
end
