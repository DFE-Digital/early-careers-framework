# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminProfile, type: :model do
  it { is_expected.to belong_to(:user) }

  describe "create_admin" do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:sign_in_url) { "www.example.com/sign-in" }

    it "creates an admin user" do
      expect {
        AdminProfile.create_admin(name, email, sign_in_url)
      }.to change { AdminProfile.count }.by(1)
    end

    it "creates a user with the correct details" do
      AdminProfile.create_admin(name, email, sign_in_url)

      created_user = User.find_by(email: email)
      expect(created_user.present?).to be(true)
      expect(created_user.full_name).to eql(name)
    end

    it "sends an email to the admin" do
      allow(AdminMailer).to receive(:account_created_email).and_call_original

      AdminProfile.create_admin(name, email, sign_in_url)

      created_user = User.find_by(email: email)
      expect(AdminMailer).to have_received(:account_created_email).with(created_user, sign_in_url)
    end
  end
end
