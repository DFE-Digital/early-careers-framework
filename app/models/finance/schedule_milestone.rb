# frozen_string_literal: true

module Finance
  class ScheduleMilestone < ApplicationRecord
    self.table_name = "schedule_milestones"

    belongs_to :schedule
    belongs_to :milestone
  end
end
