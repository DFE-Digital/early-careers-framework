# frozen_string_literal: true

module SampleData
  module Generators
    module Support
      module GeneratorUtil; end

      module GeneratorClassUtil
        def generate(*args, **kwargs, &block)
          new(*args, **kwargs).generate(&block)
        end
      end
    end
  end
end
