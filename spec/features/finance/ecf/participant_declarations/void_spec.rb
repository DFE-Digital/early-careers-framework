# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Voiding declarations" do
  let(:declaration) { ParticipantDeclaration.last }
  let(:participant_profile) { declaration.participant_profile }

  before do
    given_i_am_logged_in_as_a_finance_user
  end

  context "when there are no voidable declarations" do
    before { and_declarations_exist_but_are_not_voidable }

    scenario "Link to void declaration does not appear" do
      when_i_visit_the_participant_page
      then_i_do_not_see_the_link("Void")
    end

    scenario "Attempting to void an already voided declaration" do
      when_i_visit_the_void_declaration_page
      and_i_click("Void declaration")
      then_i_should_be_on_the_participant_page
      then_there_should_be_an_alert_banner(title: "This declaration may have already been voided", message: "Check its status and try again")
    end
  end

  context "when there are voidable declarations" do
    before { and_voidable_declarations_exist }

    scenario "User can void a declaration" do
      when_i_visit_the_participant_page
      and_i_click("Void")
      then_i_should_be_on_the_void_declaration_page

      when_i_click("Void declaration")
      then_i_should_be_on_the_participant_page
      and_there_should_be_a_success_banner(message: "Declaration voided successfully")
    end
  end

  def and_declarations_exist_but_are_not_voidable
    create(:ect_participant_declaration, :voided)
  end

  def and_voidable_declarations_exist
    create(:ect_participant_declaration, :eligible)
  end

  def when_i_visit_the_participant_page
    visit(finance_participant_path(participant_profile.user_id))
  end

  def then_i_do_not_see_the_link(link_text)
    expect(page).not_to have_link(link_text)
  end

  def then_i_should_be_on_the_void_declaration_page
    then_i_should_be_on(new_void_finance_participant_profile_ecf_participant_declarations_path(participant_profile.id, declaration.id))
  end

  def then_i_should_be_on_the_participant_page
    finance_participant_path(participant_profile.user_id)
  end

  def when_i_visit_the_void_declaration_page
    visit(new_void_finance_participant_profile_ecf_participant_declarations_path(participant_profile.id, declaration.id))
  end
end
