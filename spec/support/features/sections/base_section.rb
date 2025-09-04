# frozen_string_literal: true

module Sections
  class BaseSection < SitePrism::Section
    include RSpec::Matchers

    def element_visible?(elem)
      elem.visible? || raise(RSpec::Expectations::ExpectationNotMetError, "expected the element #{elem} to be visible")
    end

    def element_has_content?(elem, expectation)
      elem.has_content?(expectation) || raise(RSpec::Expectations::ExpectationNotMetError, "expected to find \"#{expectation}\" within\n===\n#{elem.text}\n===")
    end
  end
end
