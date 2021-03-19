# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::SupplierUsers", type: :request do
  let(:lead_provider) { create(:lead_provider) }
  let(:full_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/suppliers/users" do
    it "renders the index template" do
      get "/admin/suppliers/users"

      expect(response).to render_template(:index)
    end
  end

  describe "GET /admin/suppliers/users/new" do
    it "renders the new template" do
      get "/admin/suppliers/users/new"

      expect(response).to render_template(:new)
    end
  end

  describe "POST /admin/suppliers/new" do
    it "redirects to the user details page" do
      when_i_choose_a_supplier(lead_provider)

      expect(response).to redirect_to("/admin/suppliers/users/new/user-details")
    end

    it "Sets the correct lead provider" do
      when_i_choose_a_supplier(lead_provider)

      # Then
      given_i_have_entered_user_details(full_name, email)
      given_i_have_confirmed_my_choices

      expect(User.find_by_email(email).lead_provider).to eq lead_provider
    end

    it "Shows an error if no supplier is chosen" do
      when_i_choose_a_supplier(nil)

      # Then
      expect(response).to render_template(:new)
      expect(response.body).to include("Select one")
    end
  end

  describe "GET /admin/suppliers/users/new/user-details" do
    it "renders the user_details template" do
      given_i_have_chosen_a_supplier(lead_provider)

      # When
      get "/admin/suppliers/users/new/user-details"

      # Then
      expect(response).to render_template(:user_details)
    end
  end

  describe "POST /admin/suppliers/users/new/user-details" do
    before do
      given_i_have_chosen_a_supplier(lead_provider)
    end

    it "redirects when user details are entered" do
      when_i_enter_user_details(full_name, email)

      # Then
      expect(response).to redirect_to("/admin/suppliers/users/new/review")
    end

    it "sets the correct user details" do
      when_i_enter_user_details(full_name, email)

      # Then
      given_i_have_confirmed_my_choices
      expect(User.find_by_email(email)).not_to be_nil
      expect(User.find_by_email(email).full_name).to eq full_name
    end

    it "shows an error when an email address is in use" do
      existing_user = create(:user)

      when_i_enter_user_details(full_name, existing_user.email)

      expect(response).to render_template(:user_details)
      expect(response.body).to include("There is already a user with this email address")
    end

    it "shows an error when nothing is entered" do
      post "/admin/suppliers/users/new/user-details", params: { supplier_user_form: { full_name: "", email: "" } }

      expect(response).to render_template(:user_details)
      expect(response.body).to include("Enter a name")
      expect(response.body).to include("Enter email")
    end
  end

  describe "GET /admin/suppliers/users/new/review" do
    before do
      given_i_have_chosen_a_supplier(lead_provider)
      given_i_have_entered_user_details(full_name, email)
    end

    it "renders the review template" do
      get "/admin/suppliers/users/new/review"

      expect(response).to render_template(:review)
    end
  end

  describe "POST /admin/suppliers/users/new" do
    before do
      given_i_have_chosen_a_supplier(lead_provider)
      given_i_have_entered_user_details(full_name, email)
    end

    it "redirects to the supplier users page" do
      when_i_confirm_my_choices

      # Then
      expect(response).to redirect_to "/admin/suppliers/users"
      expect(flash[:success]).to(
        eql({
          title: "Success",
          heading: "User added",
          content: "",
        }),
      )
    end

    it "creates a new user" do
      expect {
        when_i_confirm_my_choices
      }.to change { User.count }.by(1)
    end

    it "creates a new lead provider profile" do
      expect {
        when_i_confirm_my_choices
      }.to change { LeadProviderProfile.count }.by(1)
    end
  end

private

  def when_i_choose_a_supplier(supplier)
    get "/admin/suppliers/users/new"
    post "/admin/suppliers/users/new", params: {
      supplier_user_form: { supplier: supplier&.id },
    }
  end

  alias_method :given_i_have_chosen_a_supplier, :when_i_choose_a_supplier

  def when_i_enter_user_details(full_name, email)
    get "/admin/suppliers/users/new/user-details"
    post "/admin/suppliers/users/new/user-details", params: { supplier_user_form: {
      full_name: full_name,
      email: email,
    } }
  end

  alias_method :given_i_have_entered_user_details, :when_i_enter_user_details

  def when_i_confirm_my_choices
    get "/admin/suppliers/users/new/review"
    post "/admin/suppliers/users"
  end

  alias_method :given_i_have_confirmed_my_choices, :when_i_confirm_my_choices
end
