# frozen_string_literal: true

class BaseService
  def self.call(*args, &block)
    new(*args).call(&block)
  end
end
