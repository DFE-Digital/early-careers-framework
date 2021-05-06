# frozen_string_literal: true

class DisableExtension < ActiveRecord::Migration[6.1]
  def up
    disable_extension("citext")
  end

  def down; end
end
