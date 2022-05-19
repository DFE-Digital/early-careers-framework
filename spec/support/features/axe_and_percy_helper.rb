# frozen_string_literal: true

module AxeAndPercyHelper
  extend RSpec::Matchers::DSL

  define :be_accessible do
    match do |page|
      expect(page).to be_axe_clean.according_to :wcag2aa
    end

    failure_message do |page|
      "expected #{page.current_path} to be accessible"
    end

    failure_message_when_negated do |page|
      "expected #{page.current_path} to not be accessible"
    end
  end

  def and_the_page_is_accessible
    expect(page).to be_accessible
  end

  def and_the_page_is_not_accessible
    expect(page).to_not be_accessible
  end

  def and_percy_is_sent_a_snapshot_named(name)
    page.percy_snapshot(name)
  end

  alias_method :then_the_page_is_accessible, :and_the_page_is_accessible
  alias_method :then_the_page_is_not_accessible, :and_the_page_is_not_accessible
  alias_method :then_percy_is_sent_a_snapshot_named, :and_percy_is_sent_a_snapshot_named

  module SilentPercy
    def log(*)
      super if ENV["PERCY_TOKEN"]
    end

    ::Capybara::Session.include(self)
  end
end
