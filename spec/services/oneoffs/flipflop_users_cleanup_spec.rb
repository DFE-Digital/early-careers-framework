# frozen_string_literal: true

RSpec.describe Oneoffs::FlipflopUsersCleanup do
  subject { described_class.new }

  describe "#call" do
    let!(:user1) { travel_to(4.weeks.ago) { create(:teacher_profile).user } }
    let!(:user2) { create(:teacher_profile).user }
    let!(:user3) { travel_to(4.weeks.ago) { create(:teacher_profile).user } }
    let!(:user4) { create(:teacher_profile, trn: user3.teacher_profile.trn).user }
    let!(:user5) { create(:teacher_profile, trn: user1.teacher_profile.trn).user }

    before do
      allow(subject).to receive(:flip_flop_users).and_return([user1, user2, user3, user4, user5])

      user1.archived_email = user1.email
      user1.email = "user#{user1.id}@example.org"
      user1.archived_at = Time.zone.now
      user1.save!

      user2.teacher_profile.update!(trn: nil)

      expect(Identity::Transfer).to receive(:call).with(from_user: user4, to_user: user3)
    end

    it "runs flip flop user cleanup" do
      result = subject.call
      expect(result.size).to eql(5)
      expect(result[0]).to eql([user1.id, "User is archived"])
      expect(result[1]).to eql([user2.id, "TRN does not exist"])
      expect(result[2]).to eql([user3.id, "already the primary user"])
      expect(result[3]).to eql([user4.id, "transfer to user [#{user3.id}]"])
      expect(result[4]).to eql([user5.id, "to_user [#{user1.id}] is archived"])
    end
  end

  describe "#flip_flop_users" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:user4) { create(:user) }
    let!(:user5) { create(:user) }
    let!(:user6) { create(:user) }

    before do
      # User1 -> User2
      create(:participant_id_change, user: user2, from_participant: user1, to_participant: user2)
      # User2 -> User1
      create(:participant_id_change, user: user1, from_participant: user2, to_participant: user1)

      # User3 -> User4
      create(:participant_id_change, user: user4, from_participant: user3, to_participant: user4)

      # User5 -> User6
      create(:participant_id_change, user: user6, from_participant: user5, to_participant: user6)
      # User6 -> User5
      create(:participant_id_change, user: user5, from_participant: user6, to_participant: user5)
      # User5 -> User6
      create(:participant_id_change, user: user6, from_participant: user5, to_participant: user6)
      # User6 -> User5
      create(:participant_id_change, user: user5, from_participant: user6, to_participant: user5)
    end

    it "returns flip flopped users" do
      users = subject.flip_flop_users
      expect(users.sort).to eql([user1, user2, user5, user6].sort)
    end
  end
end
