# frozen_string_literal: true

module Participants
  class ParticipantValidationForm
    include ActiveModel::Model

    attr_accessor :step
    attr_accessor :do_you_know_your_trn_choice, :have_you_changed_your_name_choice

    validates :do_you_know_your_trn_choice, presence: { message: "Tell us whether you know your teacher reference number" }, if: -> { step == :do_you_know_your_trn }
    validates :have_you_changed_your_name_choice, presence: { message: "Tell us whether you have changed your name since you started your ITT" }, if: -> { step == :have_you_changed_your_name }

    def trn_choices
      [
        OpenStruct.new(id: "yes", name: "Yes, I know my TRN"),
        OpenStruct.new(id: "no", name: "No, I do not know my TRN"),
        OpenStruct.new(id: "i_do_not_have", name: "I do not have a TRN"),
      ]
    end

    def name_change_choices
      [
        OpenStruct.new(id: "yes", name: "Yes, I changed my name"),
        OpenStruct.new(id: "no", name: "No, I have the same name"),
      ]
    end

    def complete?
      valid?
    end
  end
end
