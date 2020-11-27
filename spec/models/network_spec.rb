require "rails_helper"

RSpec.describe Network, type: :model do
  describe "network" do
    it "can be created" do
      expect {
        Network.create(name: "network")
      }.to change { Network.count }.by(1)
    end

    it { is_expected.to have_many(:schools) }
  end
end
