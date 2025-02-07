# frozen_string_literal: true

RSpec.describe Finance::ECF::ECT::OutputCalculator do
  it_behaves_like "a Finance ECF output calculator", :ect_participant_declaration
end
