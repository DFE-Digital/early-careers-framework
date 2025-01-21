# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::ECF, mid_cohort: true do
  it "sets the type from temp_type" do
    declaration = create(:mentor_participant_declaration)
    expect(declaration.type).to eq(declaration.temp_type)
  end

  describe "type validation against participant_profile" do
    it "raises an error when the declaration type is ECT and the profile type is Mentor" do
      declaration = create(:mentor_participant_declaration)

      declaration.temp_type = "ParticipantDeclaration::ECT"

      expect(declaration).to be_invalid
      expect(declaration.errors[:type]).to include(I18n.t(:declaration_type_must_match_profile_type))
    end

    it "raises an error when the declaration type is Mentor and the profile type is ECT" do
      declaration = create(:ect_participant_declaration)

      declaration.temp_type = "ParticipantDeclaration::Mentor"

      expect(declaration).to be_invalid
      expect(declaration.errors[:type]).to include(I18n.t(:declaration_type_must_match_profile_type))
    end
  end

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
end
