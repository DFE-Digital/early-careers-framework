# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NPQ::Applications::NotesController", type: :request do
  let(:application) do
    create(:npq_application,
           works_in_school: false,
           works_in_childcare: false,
           notes:)
  end
  let(:notes) { "This is a note" }
  let(:admin_user) { create :user, :admin }

  before do
    sign_in admin_user
  end

  describe "GET (EDIT) /admin/npq/applications/notes/:id/edit" do
    it "renders the index template for edge case applications and shows the notes", :aggregate_failures do
      get("/admin/npq/applications/notes/#{application.id}/edit")

      expect(response).to render_template "admin/npq/applications/notes/edit"
      expect(response.body.include?(notes)).to eq(true)
    end
  end

  describe "PATCH (UPDATE) /admin/npq/applications/notes/:id" do
    let(:new_notes) { "This is a new note" }
    let(:params) { { npq_application: { "notes"=> new_notes } } }
    let(:application_id) { application.id }

    it "renders the show template for the application", :aggregate_failures do
      patch("/admin/npq/applications/notes/#{application.id}", params:)

      expect(response).to redirect_to "/admin/npq/applications/edge_cases/#{application_id}"
      application.reload
      expect(application.notes).to eq(new_notes)
    end

    context "when the npq_applciation fails to save" do
      before do
        allow_any_instance_of(NPQApplication).to receive(:save).and_return(false)
      end

      it "returns to the edit page", :aggregate_failures do
        patch("/admin/npq/applications/notes/#{application.id}", params:)
        expect(flash[:alert]).not_to be_empty
        expect(response.status).to eq(400)
        expect(response.parsed_body.include?(new_notes)).to eq(true)
        application.reload
        expect(application.notes).to eq(notes)
      end
    end
  end
end
