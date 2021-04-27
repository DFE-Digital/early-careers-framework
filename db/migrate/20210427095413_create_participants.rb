# frozen_string_literal: true

class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table(:participants, id: :uuid, &:timestamps)
  end
end
