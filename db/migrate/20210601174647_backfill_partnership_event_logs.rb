# frozen_string_literal: true

class BackfillPartnershipEventLogs < ActiveRecord::Migration[6.1]
  class Partnership < ApplicationRecord
  end

  class EventLog < ApplicationRecord
  end

  def up
    Partnership.find_each do |partnership|
      EventLog.create!(
        owner_type: "Partnership",
        owner_id: partnership.id,
        event: :reported,
        created_at: partnership.created_at,
        updated_at: partnership.created_at,
        data: { backfilled: true },
      )

      if partnership.challenged_at.present?
        EventLog.create!(
          owner_type: "Partnership",
          owner_id: partnership.id,
          event: :challenged,
          created_at: partnership.challenged_at,
          updated_at: partnership.challenged_at,
          data: {
            reason: partnership.challenge_reason,
            backfilled: true,
          },
        )
      end
    end
  end

  def down
    EventLog.where("(data->>'backfilled')::boolean").delete_all
  end
end
