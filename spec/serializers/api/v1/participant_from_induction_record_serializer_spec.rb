# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ParticipantFromInductionRecordSerializer, :with_default_schedules do
      let(:ect) { create(:ect) }
      let(:induction_record) { ect.induction_records.first }

      subject { described_class.new(induction_record) }

      describe "#status" do
        context "when active" do
          it "returns active" do
            expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
          end
        end

        context "when the status has changed" do
          context "when completed" do
            before { induction_record.completed_induction_status! }

            it "returns active" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
            end
          end

          context "when leaving" do
            let(:induction_record) { ect.reload.current_induction_record }
            before { induction_record.leaving! }

            it "returns active" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("active")
            end
          end

          context "when withdrawn" do
            before { induction_record.withdrawing! }

            it "returns withdrawn" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("withdrawn")
            end
          end

          context "when changed" do
            before { induction_record.changing! }

            it "returns withdrawn" do
              expect(subject.serializable_hash[:data][:attributes][:status]).to eq("withdrawn")
            end
          end
        end
      end

      describe "#email" do
        subject { described_class.new(ect.reload.current_induction_record) }
        before do
          Induction::ChangePreferredEmail.call(induction_record:, preferred_email: "second_email@example.com")
        end

        it "returns preferred identity email" do
          expect(subject.serializable_hash[:data][:attributes][:email]).to eql("second_email@example.com")
        end
      end

      describe "#training_record_id" do
        subject { described_class.new(ect.reload.current_induction_record) }

        it "returns the training_status" do
          expect(subject.serializable_hash[:data][:attributes][:training_record_id]).to eql(ect.id)
        end
      end

      describe "#updated_at" do
        let(:user) { induction_record.participant_profile.user }
        let(:profile) { induction_record.participant_profile }
        let(:identity) { induction_record.participant_profile.participant_identity }

        context "when induction record touched" do
          before do
            ActiveRecord::Base.no_touching do
              user.update!(updated_at: 10.days.ago)
              profile.update!(updated_at: 10.days.ago)
              induction_record.update!(updated_at: 1.day.ago)
              identity.update!(updated_at: 10.days.ago)
            end
          end

          it "considers updated_at of induction record" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to be_within(2.hours).of(1.day.ago)
          end
        end

        context "when user touched" do
          before do
            ActiveRecord::Base.no_touching do
              user.update!(updated_at: 1.day.ago)
              profile.update!(updated_at: 10.days.ago)
              induction_record.update!(updated_at: 10.days.ago)
              identity.update!(updated_at: 10.days.ago)
            end
          end

          it "considers updated_at of user" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to be_within(2.hours).of(1.day.ago)
          end
        end

        context "when profile touched" do
          before do
            ActiveRecord::Base.no_touching do
              user.update!(updated_at: 10.days.ago)
              profile.update!(updated_at: 1.day.ago)
              induction_record.update!(updated_at: 10.days.ago)
              identity.update!(updated_at: 10.days.ago)
            end
          end

          it "considers updated_at of profile" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to be_within(2.hours).of(1.day.ago)
          end
        end

        context "when identity touched" do
          before do
            ActiveRecord::Base.no_touching do
              user.update!(updated_at: 10.days.ago)
              profile.update!(updated_at: 10.days.ago)
              induction_record.update!(updated_at: 10.days.ago)
              identity.update!(updated_at: 1.day.ago)
            end
          end

          it "considers updated_at of identity" do
            expect(Time.zone.parse(subject.serializable_hash[:data][:attributes][:updated_at])).to be_within(2.hours).of(1.day.ago)
          end
        end
      end
    end
  end
end
