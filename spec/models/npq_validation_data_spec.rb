# frozen_string_literal: true

RSpec.describe NPQValidationData, type: :model do
  it {
    is_expected.to define_enum_for(:headteacher_status).with_values(
      no: "no",
      yes_when_course_starts: "yes_when_course_starts",
      yes_in_first_two_years: "yes_in_first_two_years",
      yes_over_two_years: "yes_over_two_years",
    ).backed_by_column_of_type(:text)
  }

  describe "profile synchronisation" do
    let(:trn) { Array.new(10) { rand 0..9 }.join }
    let(:validation_data) do
      described_class.new(
        teacher_reference_number: trn,
        user: create(:user),
        npq_course: create(:npq_course),
        npq_lead_provider: create(:npq_lead_provider),
      )
    end

    context "on create" do
      it "creates teacher and participant profile" do
        expect { validation_data.save! }
          .to change(TeacherProfile, :count).by(1)
          .and change(ParticipantProfile::NPQ, :count).by(1)
      end

      it "stores the TRN on teacher profile" do
        validation_data.tap(&:save!).reload
        expect(validation_data.user.teacher_profile.trn).to eq trn
      end
    end

    context "on update" do
      before { validation_data.tap(&:save!).reload }
      let(:new_trn) { Array.new(10) { rand 0..9 }.join }

      it "does not create neither teacher nor participant profile" do
        expect { validation_data.update!(teacher_reference_number: new_trn) }
          .to change(TeacherProfile, :count).by(0)
          .and change(ParticipantProfile::NPQ, :count).by(0)
      end

      it "updates the TRN on teacher profile" do
        validation_data.update!(teacher_reference_number: new_trn)
        expect(validation_data.reload.user.teacher_profile.trn).to eq new_trn
      end
    end
  end
end
