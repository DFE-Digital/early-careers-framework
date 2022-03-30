# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQ < Schedule
    end
  end
end

require "finance/schedule/npq_leadership"
require "finance/schedule/npq_specialist"
require "finance/schedule/npq_support"
