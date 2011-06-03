#!/usr/bin/env ruby

require 'test/unit'
require 'prefix'

class PrefixerTest < Test::Unit::TestCase
  
  def test_simple_arithmetic
    assert_equal("+ 1 1", Prefixer.new("1 + 1").convert)
    assert_equal("+ * 2 5 1", Prefixer.new("2 * 5 + 1").convert)
  end
  
  def test_simple_arithmetic_reduce
    assert_equal("2.0", Prefixer.new("1 + 1",true).convert)
    assert_equal("11.0", Prefixer.new("2 * 5 + 1",true).convert)
  end
  
  def test_simple_algebra
    assert_equal("+ a b", Prefixer.new("a + b").convert)
    assert_equal("- * a b / 1 1", Prefixer.new("a * b - 1 / 1").convert)
  end

  def test_simple_algebra_reduce
    assert_equal("+ a b", Prefixer.new("a + b",true).convert)
    assert_equal("- * a b 1", Prefixer.new("a * b - 1 / 1",true).convert)
    assert_equal("3.0", Prefixer.new("3 * ( y / y ) + ( x - x ) / ( y / y )",true).convert)
  end
  
  def test_complex_arithmetic
    assert_equal("* 2 + 5 1", Prefixer.new("2 * ( 5 + 1 )").convert)
    assert_equal("* 3 * 50 / 12 * 20 20", Prefixer.new("3 * 50 * 12 / ( 20 * 20 )").convert)
  end

  def test_complex_arithmetic_reduce
    assert_equal("12.0", Prefixer.new("2 * ( 5 + 1 )",true).convert)
    assert_equal("4.5", Prefixer.new("3 * 50 * 12 / ( 20 * 20 )",true).convert)
  end
  
  def test_complex_algebra
    assert_equal("- * 3 * y y / + 0 0 * / 0 1 / 1 1", Prefixer.new("3 * ( y * y ) - ( 0 + 0 ) / ( 0 / 1 ) * ( 1 / 1 )").convert)
  end

  def test_complex_algebra_reduce
    assert_equal("* 3 * y y", Prefixer.new("3 * ( y * y ) - ( 0 + 0 ) / ( 0 / 1 ) * ( 1 / 1 )", true).convert)
  end
  
end