# frozen_string_literal: true

module Meta
  def meta_self
    class << self
      self
    end
  end

  def meta_def(name, &blk)
    meta_self.instance_eval { define_method name, &blk }
  end
end
