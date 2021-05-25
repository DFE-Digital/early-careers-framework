# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead provider partnerships spec", type: :request do
  let(:user) { create :user, :lead_provider }
  let(:cohort) { create :cohort }

  before do
    sign_in user
  end

  describe "GET /lead-providers/partnerships/:id" do
    context "when the current user belongs to the partnership's lead provider organisation" do
      let(:partnership) { create :partnership, cohort: cohort, lead_provider: user.lead_provider }

      it "should show the partnership page" do
        get lead_providers_partnership_path(partnership)

        expect(response).to render_template :show
        expect(assigns(:partnership)).to eq partnership
      end
    end

    context "when the current user does not belong to the partnership's lead provider organisation" do
      let(:partnership) { create :partnership, cohort: cohort }

      it "should show the partnership page" do
        expect { get lead_providers_partnership_path(partnership) }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
