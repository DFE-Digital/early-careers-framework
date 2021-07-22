# frozen_string_literal: true

describe CreateFinanceUser do
  it "Creates finance user" do
    email = "bobby.tables@example.com"
    described_class.call("Bobby Tables", email)
    user = User.find_by!(email: email)
    expect(user).to be_finance
    expect(user).not_to be_admin
  end
end
