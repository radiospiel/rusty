require_relative './helper'

class TestDx < Test::Unit::TestCase
  def dx
    @dx ||= Rusty::DX.new
  end

  def test_as_nil
    assert_false dx.list?
    assert_false dx.dict?
    
    assert_equal(nil, dx.to_ruby)
  end

  def test_inspect
    assert_equal("<nil>", dx.inspect)
    dx << 1
    assert_equal("<[1]>", dx.inspect)
  end
  
  def test_as_list
    dx[3] # turn dx into a list, but still with no content
    assert_true dx.list?
    assert_false dx.dict?
    
    assert_raise(ArgumentError) {  
      dx.foo = "bar"
    }

    assert_equal([], dx.to_ruby)
  end

  def test_create_list_by_pushing
    dx << 1
    assert_equal([1], dx.to_ruby)
  end

  def test_create_dict_by_key
    dx.key?(:a)
    assert_equal({}, dx.to_ruby)
  end
  
  def test_as_dict
    dx.abc
    dx.abc
    assert_true dx.dict?
    assert_false dx.list?
    
    dx[2] = "bar"
    assert_true dx.dict?
    assert_false dx.list?

    assert_equal({"abc"=>nil, 2=>"bar"}, dx.to_ruby)
  end
  
  def test_undefined_method
    assert_raise(NoMethodError) {  
      dx.abc(1,2,3)
    }
  end
  
end
