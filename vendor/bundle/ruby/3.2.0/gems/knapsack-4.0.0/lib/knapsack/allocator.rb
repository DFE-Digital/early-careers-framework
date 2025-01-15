module Knapsack
  class Allocator
    def initialize(args={})
      @report_distributor = Knapsack::Distributors::ReportDistributor.new(args)
      @leftover_distributor = Knapsack::Distributors::LeftoverDistributor.new(args)
    end

    def report_node_tests
      @report_node_tests ||= @report_distributor.tests_for_current_node
    end

    def leftover_node_tests
      @leftover_node_tests ||= @leftover_distributor.tests_for_current_node
    end

    def node_tests
      @node_tests ||= report_node_tests + leftover_node_tests
    end

    def stringify_node_tests
      node_tests
      .map do |test_file|
        %{"#{test_file}"}
      end.join(' ')
    end

    def test_dir
      Knapsack::Config::Env.test_dir || @report_distributor.test_file_pattern.split('/').first
    end
  end
end
