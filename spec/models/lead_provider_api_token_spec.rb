# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderApiToken, type: :model do
  it "generates a hashed token that can be used" do
    unhashed_token = LeadProviderApiToken.create_with_random_token!(lead_provider: create(:lead_provider))

    expect(
      LeadProviderApiToken.find_by_unhashed_token(unhashed_token),
    ).to eql(LeadProviderApiToken.order(:created_at).last)
  end
end
