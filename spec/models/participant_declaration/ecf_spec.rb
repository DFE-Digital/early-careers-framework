# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::ECF, mid_cohort: true do
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
      subject { create(:ect_participant_declaration, :paid, uplifts: [:pupil_premium_uplift], declaration_type: "retained-1") }

      it "should return false" do
        expect(subject.uplift_paid?).to eql(false)
      end
    end
  end

  describe "before_save set_temp_type" do
    subject { declaration.temp_type }

    context "when an ECT declaration" do
      let(:declaration) { create(:ect_participant_declaration) }

      it { is_expected.to eq("ParticipantDeclaration::ECT") }
    end

    context "when a Mentor declaration" do
      let(:declaration) { create(:mentor_participant_declaration) }

      it { is_expected.to eq("ParticipantDeclaration::Mentor") }
    end
  end
end
