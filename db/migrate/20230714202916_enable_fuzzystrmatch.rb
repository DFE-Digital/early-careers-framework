# frozen_string_literal: true

class EnableFuzzystrmatch < ActiveRecord::Migration[7.0]
  def change
    enable_extension "fuzzystrmatch"
  end
end
