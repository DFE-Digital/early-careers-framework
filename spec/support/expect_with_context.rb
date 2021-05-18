# frozen_string_literal: true

# Adding the customized failure message loses then nice expected/got output so
# we have to recreate that output if we want context such as which row we are looking at in a loop.
def expect_with_context(actual, expected, additional_context)
  expect(actual).to eq(expected), "Expected: #{expected}. Got: #{actual}. Context: #{additional_context}"
end
