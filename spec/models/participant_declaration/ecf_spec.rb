# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::ECF do
  describe "#uplift_paid?" do
    %i[paid awaiting_clawback clawed_back].each do |declaration_state|
      context "started - ecf-induction - #{declaration_state} - sparsity_uplift" do
        subject { create(:ect_participant_declaration, declaration_state, uplifts: [:sparsity_uplift], declaration_type: "started") }

        it "should return true" do
          expect(subject.uplift_paid?).to eql(true)
        end
      end

      context "started - ecf-induction - #{declaration_state} - pupil_premium_uplift" do
        subject { create(:ect_participant_declaration, declaration_state, uplifts: [:pupil_premium_uplift], declaration_type: "started") }

        it "should return true" do
          expect(subject.uplift_paid?).to eql(true)
        end
      end
    end

    context "retained-1 - ecf-induction - paid - pupil_premium_uplift" do
      let(:schedule) { Finance::Schedule.find_by(schedule_identifier: "ecf-standard-september", cohort: Cohort.current) }

      subject do
        travel_to schedule.milestones.find_by!(declaration_type: "retained-1").start_date + 2.days do
          create(:ect_participant_declaration, :paid, uplifts: [:pupil_premium_uplift], declaration_type: "retained-1")
        end
      end

      it "should return false" do
        expect(subject.uplift_paid?).to eql(false)
      end
    end
  end
end
