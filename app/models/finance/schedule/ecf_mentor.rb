# frozen_string_literal: true

class Finance::Schedule::ECFMentor < Finance::Schedule::ECF
  def self.permitted_course_identifiers
    %w[ecf-mentor]
  end
end
