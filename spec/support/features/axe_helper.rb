# frozen_string_literal: true

module AxeHelper
  extend RSpec::Matchers::DSL

  define :be_accessible do
    match do |page|
      expect(page).to be_axe_clean.according_to :wcag2aa
    end
  end

  def and_the_page_is_accessible
    expect(page).to be_accessible
  end

  alias_method :then_the_page_is_accessible, :and_the_page_is_accessible

  # TODO: old speculative syntax to be removed
  alias_method :and_the_page_should_be_accessible, :then_the_page_is_accessible
  alias_method :then_the_page_should_be_accessible, :then_the_page_is_accessible
end
