# frozen_string_literal: true

module Declarable
  extend ActiveSupport::Concern

  included do
    has_one :profile_declaration, as: :declarable, touch: true
  end
end
