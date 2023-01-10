# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module Finance
      RSpec.describe StatementSerializer do
        describe "serialization" do
          let(:cohort) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
          let(:statement) { create(:ecf_statement, name: "January 2022", cohort:) }
          subject(:serialiser) { described_class.new(statement) }

          it "returns the month" do
            expect(serialiser.serializable_hash[:data][:attributes][:month]).to eq("January")
          end

          it "returns the year" do
            expect(serialiser.serializable_hash[:data][:attributes][:year]).to eq("2022")
          end

          it "returns the cohort start year" do
            expect(serialiser.serializable_hash[:data][:attributes][:cohort]).to eq("2022")
          end

          it "returns the cut off dates" do
            expect(serialiser.serializable_hash[:data][:attributes][:cut_off_date]).to eq(statement.deadline_date.rfc3339)
          end

          it "returns the payment dates" do
            expect(serialiser.serializable_hash[:data][:attributes][:payment_date]).to eq(statement.payment_date.rfc3339)
          end

          context "with an ECF statement" do
            it "returns the type" do
              expect(serialiser.serializable_hash[:data][:attributes][:type]).to eq("ecf")
            end

            it "returns the paid status of the statement" do
              expect(serialiser.serializable_hash[:data][:attributes][:paid]).to be(false)
            end

            context "when paid" do
              let(:statement) { create(:ecf_paid_statement) }

              it "returns the paid status of the statement" do
                expect(serialiser.serializable_hash[:data][:attributes][:paid]).to be(true)
              end
            end
          end

          context "with an NPQ statement" do
            let(:statement) { create(:npq_statement) }

            it "returns the type" do
              expect(serialiser.serializable_hash[:data][:attributes][:type]).to eq("npq")
            end

            it "returns the paid status of the statement" do
              expect(serialiser.serializable_hash[:data][:attributes][:paid]).to be(false)
            end

            context "when paid" do
              let(:statement) { create(:npq_paid_statement) }

              it "returns the paid status of the statement" do
                expect(serialiser.serializable_hash[:data][:attributes][:paid]).to be(true)
              end
            end
          end
        end
      end
    end
  end
end
