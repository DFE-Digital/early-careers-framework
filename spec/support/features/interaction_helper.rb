# frozen_string_literal: true

module InteractionHelper
  include Capybara::DSL

  alias_method :when_i_click, :click_on
  alias_method :and_i_click, :click_on

  alias_method :when_i_click_the_link_containing, :click_link
  alias_method :and_i_click_the_link_containing, :click_link

  alias_method :when_i_fill_in, :fill_in

  def when_i_select(label)
    choose(label, allow_label_click: true)
  end

  alias_method :and_i_select, :when_i_select

  def when_i_click_the_button_labelled(label)
    click_button label, class: "govuk-button", type: "submit"
  end

  def when_i_click_the_save_button
    when_i_click_the_button_labelled("Save")
  end

  alias_method :and_i_click_the_save_button, :when_i_click_the_save_button

  def when_i_click_the_continue_button
    when_i_click_the_button_labelled("Continue")
  end

  alias_method :and_i_click_the_continue_button, :when_i_click_the_continue_button

  def then_i_should_be_on(path)
    expect(page).to have_current_path path
  end

  alias_method :and_i_should_be_on, :then_i_should_be_on

  def when_i_visit(path)
    visit path
  end

  alias_method :and_i_visit, :when_i_visit

  def when_i_sign_out
    click_on "Sign out"
    expect(page).to have_selector("h1", text: "You’re now signed out")
  end

  alias_method :and_i_sign_out, :when_i_sign_out

  def when_i_fill_in_autocomplete(id, with:)
    page.execute_script("document.getElementById('#{id}').value = '#{with}';")

    within("ul##{id}__listbox") do
      find("li.autocomplete__option", match: :first).select_option
    end
  end

  alias_method :and_i_fill_in_autocomplete, :when_i_fill_in_autocomplete

  def when_i_click_on_summary_row_action(row_key, selector)
    key_node = find("dt.govuk-summary-list__key", text: row_key)
    actions_node = key_node.sibling("dd.govuk-summary-list__actions")
    within(actions_node) do
      click_on selector
    end
  end

  alias_method :and_i_click_on_summary_row_action, :when_i_click_on_summary_row_action
end
