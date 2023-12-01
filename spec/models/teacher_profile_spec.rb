# frozen_string_literal: true

require "rails_helper"

RSpec.describe(TeacherProfile, type: :model) do
  describe(:oldest_first) do
    specify "constructs the right order by clause" do
      expect(TeacherProfile.oldest_first.to_sql).to match(/ORDER BY "teacher_profiles"."created_at" ASC/)
    end
  end
end
