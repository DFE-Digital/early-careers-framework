# frozen_string_literal: true

RSpec.describe Finance::Statement::Base do
  describe "associations" do
    it "can fetch associated participant_declarations" do
      subject.participant_declarations << build(:participant_declaration)
      subject.participant_declarations.size == 1
    end
  end
end
