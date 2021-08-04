# frozen_string_literal: true

module RecordDeclarations
  module Mentor
    extend ActiveSupport::Concern

    included do
      include ECF
      delegate :mentor_profile, to: :user
    end

    def user_profile
      mentor_profile
    end
  end
end
