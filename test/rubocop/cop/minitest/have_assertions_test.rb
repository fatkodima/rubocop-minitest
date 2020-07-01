# frozen_string_literal: true

require 'test_helper'

class HaveAssertionsTest < Minitest::Test
  def test_registers_offense_when_there_are_no_assertions
    assert_offense(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
            ^^^^^^^^^^^^^^^^^ Test case should have at least 1 assertion.
          do_something
        end
      end
    RUBY
  end

  def test_registers_offense_when_multiple_test_cases_and_there_are_no_assertions
    assert_offense(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
            ^^^^^^^^^^^^^^^^^ Test case should have at least 1 assertion.
          do_something
        end

        def test_do_something_other
            ^^^^^^^^^^^^^^^^^^^^^^^ Test case should have at least 1 assertion.
          do_something_other
        end
      end
    RUBY
  end

  def test_does_not_register_offense_when_there_are_assertions
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_equal 42, do_something
        end
      end
    RUBY
  end

  def test_checks_only_test_case_methods
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def do_something
          do_something_other
        end
      end
    RUBY
  end

  def test_checks_only_minitest_test_children
    assert_no_offenses(<<~RUBY)
      class FooTest
        def test_do_something
          something_other
        end
      end
    RUBY
  end

  def test_does_not_register_offense_when_custom_assertion
    cop_config = RuboCop::Config.new('Minitest/HaveAssertions' => {
                                       'CustomAssertions' => ['custom_assert']
                                     })
    @cop = RuboCop::Cop::Minitest::HaveAssertions.new(cop_config)

    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          custom_assert do_something
        end
      end
    RUBY
  end
end
