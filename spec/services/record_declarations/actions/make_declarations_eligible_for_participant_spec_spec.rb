# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipant do
  context '#call' do
    create!(:user, :early_career_teacher)
    %w[started retained-1 retained-2 retained-3 retained-4 completed].each do |declaration_type|
      create(:ect_participant_declaration, declaration_type: declaration_type)
    end

    it 'starts with all declarations set to submitted' do
      ParticipantDeclaration.all.each do |participant_declaration|
        expect(participant_declaration.submitted?).to be_truthy
      end
    end

    it 'marks any submitted declarations for the participant as eligible' do

    end
  end
end
