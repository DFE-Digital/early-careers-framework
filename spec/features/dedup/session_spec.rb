# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Dedup: maintaining session after identity transfer", :with_default_schedules, :js do
  let(:original_user) { create(:ect).user }
  let(:target_user)   { create(:npq_participant_profile).user }

  before do
    Identity::Transfer.call(from_user: original_user, to_user: target_user)
  end

  it "silently switches current_user onto user to which we transferred identity" do
    sign_in_as original_user
    expect(page).to have_no_content "You are impersonating"
  end
end
