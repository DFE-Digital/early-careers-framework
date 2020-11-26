require "rails_helper"

RSpec.describe Network, type: :model do
  describe "network" do
    it "can be created" do
      expect {
        Network.create(
          name: "network",
        )
      }.to change { Network.count }.by(1)
    end

    it "can receive a school" do
      school = FactoryBot.create(:school)
      network = Network.create!(
        name: "network",
      )
      school.network = network

      expect(school.network.name).to eq("network")
    end

    it "can receive two schools" do
      network = Network.create!(
        name: "network",
      )
      school_one = FactoryBot.create(:school, network: network)
      school_two = FactoryBot.create(:school, urn: "TEST URN 2", network: network)

      expect(network.schools.count).to eq(2)
      expect(network.schools).to include(school_two, school_one)
    end
  end
end
