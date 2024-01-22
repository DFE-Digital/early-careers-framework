# frozen_string_literal: true

RSpec.describe Oneoffs::NPQ::BackfillTrnToTeacherProfile do
  let(:application1) { create(:npq_application, :funded, :accepted) }
  let(:user_with_application1) { application1.user }
  let(:teacher_profile1) { user_with_application1.teacher_profile }

  let(:application2) { create(:npq_application, :funded, :accepted) }
  let(:user_with_application2) { application2.user }
  let(:teacher_profile2) { user_with_application2.teacher_profile }

  let(:application3) { create(:npq_application, :funded, :accepted, user: user_with_application2) }

  let(:trn1) { "1234567" }
  let(:trn2) { "1234568" }
  let(:trn3) { "1234569" }

  before do
    application1
    application2
    application3

    teacher_profile1.update!(trn: nil)
    teacher_profile2.update!(trn: nil)

    application1.update!(teacher_reference_number: trn1)
    application2.update!(teacher_reference_number: trn2)
    application3.update!(teacher_reference_number: trn3)
  end

  context "when script is applied" do
    it "backfills the missing trn when trn can be determined" do
      expect {
        subject.migrate
      }.to change { teacher_profile1.reload.trn }.from(nil).to(trn1)
    end

    it "doesn't backfills the missing trn when trn can not be determined" do
      expect {
        subject.migrate
      }.not_to change { teacher_profile2.reload.trn }
    end
  end
end
