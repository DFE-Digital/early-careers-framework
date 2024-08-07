# frozen_string_literal: true

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

  describe "whitespace stripping" do
    let(:network) { create(:network, secondary_contact_email: " \tgordo@example.com \n ") }

    it "strips whitespace from emails" do
      network.valid?
      expect(network.secondary_contact_email).to eq "gordo@example.com"
    end
  end
end
