# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Minitest
      # This cop enforces that there is at least 1 assertion per test case.
      #
      # @example CustomAssertions: [] (default)
      #   # bad
      #   class FooTest < Minitest::Test
      #     def test_do_something
      #       # There are no assertions
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   class FooTest < Minitest::Test
      #     def test_do_something
      #       # There is an assertion
      #       assert_equal 42, do_something
      #     end
      #   end
      #
      # @example CustomAssertions: ['assert_something']
      #   # good
      #   class FooTest < Minitest::Test
      #     def test_do_something
      #       assert_something do_something
      #     end
      #   end
      #
      class HaveAssertions < Cop
        include MinitestExplorationHelpers

        MSG = 'Test case should have at least 1 assertion.'

        ASSERTIONS_LIKE_METHODS = %i[
          fail_after
          flunk
          pass
          skip
        ].to_set.freeze

        def on_class(class_node)
          return unless minitest_test_subclass?(class_node)

          test_cases(class_node).each do |node|
            add_offense(node, location: :name) unless contains_assertions?(node)
          end
        end

        private

        def contains_assertions?(node)
          node.each_child_node.any? do |child|
            if assertion?(child) ||
               assertion_like_method?(child) ||
               custom_assertion?(child)
              true
            else
              contains_assertions?(child)
            end
          end
        end

        def assertion_like_method?(node)
          node.send_type? &&
            ASSERTIONS_LIKE_METHODS.include?(node.method_name)
        end

        def custom_assertion?(node)
          return unless node.send_type?

          custom_assertions = Array(cop_config['CustomAssertions']).map(&:to_sym)
          custom_assertions.include?(node.method_name)
        end
      end
    end
  end
end
