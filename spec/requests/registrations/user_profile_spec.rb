# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::UserProfile", type: :request do
  let(:school) { create(:school) }
 
  describe "GET /registrations/user-profile/new" do
    let(:session) {  { school_urn: school.urn } }
  
    before do
      allow_any_instance_of(Registrations::UserProfileController)
        .to receive(:session)
        .and_return(session)      
    end

    it "renders the show template" do
      get "/registrations/user-profile/new"
      expect(response).to render_template("registrations/user_profile/new")
    end
  end
end
