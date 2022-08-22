# frozen_string_literal: true

module AxeAndPercyHelper
  extend RSpec::Matchers::DSL

  define :be_accessible do
    match do |page|
      expect(page).to be_axe_clean.according_to :wcag2aa
    end
  end

  def and_the_page_is_accessible
    expect(page).to be_accessible
  end

  def and_percy_is_sent_a_snapshot_named(name)
    page.percy_snapshot(name)
  rescue StandardError => e
    raise e unless e.message =~ /Can only finalize pending builds/

    Rails.logger.error(e.message)
  end

  alias_method :then_the_page_is_accessible, :and_the_page_is_accessible
  alias_method :then_percy_is_sent_a_snapshot_named, :and_percy_is_sent_a_snapshot_named

  # TODO: old speculative syntax to be removed
  alias_method :and_the_page_should_be_accessible, :then_the_page_is_accessible
  alias_method :then_the_page_should_be_accessible, :then_the_page_is_accessible
  alias_method :and_percy_should_be_sent_a_snapshot_named, :then_percy_is_sent_a_snapshot_named
  alias_method :then_percy_should_be_sent_a_snapshot_named, :then_percy_is_sent_a_snapshot_named

  module SilentPercy
    def log(*)
      super if ENV["PERCY_TOKEN"]
    end

    ::Capybara::Session.include(self)
  end
end
