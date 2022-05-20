# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ParticipantFromInductionRecordSerializer do
      let(:induction_record) { create(:induction_record) }

      subject { described_class.new(induction_record) }

      describe "#status" do
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

      describe "#updated_at" do
        let(:induction_record) { create(:induction_record, updated_at: 1.day.ago) }
        let(:user) { induction_record.participant_profile.user }

        before do
          user.update!(updated_at: 10.days.ago)
        end

        it "considers updated_at of induction record" do
          expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to be_within(2.days).of(1.day.ago)
        end
      end
    end
  end
end
