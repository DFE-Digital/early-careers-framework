# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeadProvider::ConfirmPartnerships", type: :request do
  let(:school) { create(:school) }

  context "signed in as a lead provider user" do
    before do
      user = create(:user, :lead_provider)
      sign_in user
    end

    describe "create" do
      before do
        post "/lead-provider/confirm-partnerships", params: { partnership_form: { schools: [school.id] } }
      end
      it "renders the confirmation page" do
        expect(response).to render_template(:create)
      end

      it "shows the names of the schools to be partnered" do
        expect(response.body).to include(CGI.escapeHTML(school.name))
      end
    end
  end

  context "signed in as a different user" do
    before do
      user = create(:user)
      sign_in user
    end

    it "raises not authorized" do
      expect {
        post "/lead-provider/confirm-partnerships", params: { partnership_form: { schools: [school.id] } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
