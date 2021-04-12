# frozen_string_literal: true

require Rails.root.join("lib/devise/strategies/yolo_authenticatable")

module Devise
  module Models
    module YoloAuthenticatable
      extend ActiveSupport::Concern
    end
  end
end
