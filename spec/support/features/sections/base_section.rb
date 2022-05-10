# frozen_string_literal: true

module Sections
  class BaseSection < SitePrism::Section
    include RSpec::Matchers

    def element_visible?(elem)
      if elem.visible?
        true
      else
        raise RSpec::Expectations::ExpectationNotMetError, "expected the element #{el} to be visible"
      end
    end

    def element_has_content?(elem, expectation)
      if elem.has_content? expectation
        true
      else
        raise RSpec::Expectations::ExpectationNotMetError, "expected to find \"#{expectation}\" within\n===\n#{el.text}\n==="
      end
    end
  end
end
