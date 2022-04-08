# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ParticipantFromInductionRecordSerializer do
      let(:induction_record) { create(:induction_record) }

      subject { described_class.new(induction_record) }

      describe "status" do
        context "when active" do
          it "returns active" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eql("active")
          end
        end

        context "when completed" do
          let(:induction_record) { create(:induction_record, induction_status: "completed") }

          it "returns active" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eql("active")
          end
        end

        context "when leaving" do
          let(:induction_record) { create(:induction_record, induction_status: "leaving") }

          it "returns active" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eql("active")
          end
        end

        context "when withdrawn" do
          let(:induction_record) { create(:induction_record, induction_status: "withdrawn") }

          it "returns withdrawn" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eql("withdrawn")
          end
        end

        context "when changed" do
          let(:induction_record) { create(:induction_record, induction_status: "changed") }

          it "returns withdrawn" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eql("withdrawn")
          end
        end
      end
    end
  end
end
