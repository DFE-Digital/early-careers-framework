# frozen_string_literal: true

require "rails_helper"

RSpec.describe "rake admin:create", type: :task do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  it "calls create_admin" do
    url = "http://www.example.com/users/sign_in"
    expect(AdminProfile).to receive(:create_admin).with(name, email, url)

    capture_output { task.execute(to_task_arguments(name, email)) }
  end
end
