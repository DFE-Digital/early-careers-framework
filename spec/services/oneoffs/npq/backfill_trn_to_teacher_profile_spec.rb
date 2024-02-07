# frozen_string_literal: true

RSpec.describe Oneoffs::NPQ::BackfillTrnToTeacherProfile do
  let(:application1) { create(:npq_application, :funded, :accepted) }
  let(:user_with_application1) { application1.user }
  let!(:teacher_profile1) { user_with_application1.teacher_profile.tap { |tp| tp.update!(trn: nil) } }

  let(:application2) { create(:npq_application, :funded, :accepted) }
  let(:user_with_application2) { application2.user }
  let!(:teacher_profile2) { user_with_application2.teacher_profile.tap { |tp| tp.update!(trn: nil) } }

  let!(:application3) { create(:npq_application, :funded, :accepted, user: user_with_application2) }

  it "backfills the missing trn when the trn can be determined and is verified" do
    expect {
      subject.migrate
    }.to change { teacher_profile1.reload.trn }.from(nil).to(application1.teacher_reference_number)
  end

  it "does not backfill the missing trn when trn can not be determined" do
    expect {
      subject.migrate
    }.not_to change { teacher_profile2.reload.trn }
  end

  it "does not backfill the missing trn with an unverified trn" do
    application1.update!(teacher_reference_number_verified: false)

    expect {
      subject.migrate
    }.not_to change { teacher_profile1.reload.trn }
  end

  it "does not backfill the missing trn if the verified trn is not valid" do
    application1.update!(teacher_reference_number: "invalid-trn")

    expect {
      subject.migrate
    }.not_to change { teacher_profile1.reload.trn }
  end

  it "does not backfill the missing trn if there are multiple applications with different, verified trns" do
    application2.update!(participant_identity: user_with_application1.participant_identities.sample)

    expect {
      subject.migrate
    }.not_to change { teacher_profile1.reload.trn }
  end

  it "backfills the missing trn if there are multiple applications with the same, verified trn" do
    application2.update!(
      teacher_reference_number: application1.teacher_reference_number,
      participant_identity: user_with_application1.participant_identities.sample,
    )

    expect {
      subject.migrate
    }.to change { teacher_profile1.reload.trn }.from(nil).to(application1.teacher_reference_number)
  end
end
