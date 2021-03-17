# frozen_string_literal: true

require "rails_helper"

RSpec.describe "rake admin:create", type: :task do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  it "creates an admin user" do
    expect {
      task.execute(to_task_arguments(name, email))
    }.to change { AdminProfile.count }.by(1)
  end

  it "creates a user with the correct details" do
    task.execute(to_task_arguments(name, email))

    created_user = User.find_by(email: email)
    expect(created_user.present?).to be(true)
    expect(created_user.full_name).to eql(name)
  end

  it "sends an email to the admin" do
    url = "http://www.example.com/users/sign_in"
    allow(AdminMailer).to receive(:account_created_email).and_call_original

    task.execute(to_task_arguments(name, email))

    created_user = User.find_by(email: email)
    expect(AdminMailer).to have_received(:account_created_email).with(created_user, url)
  end
end
