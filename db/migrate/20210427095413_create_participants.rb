class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :participants, id: :uuid do |t|
      t.timestamps
    end
  end
end
