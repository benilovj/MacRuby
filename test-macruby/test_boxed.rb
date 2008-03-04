require 'test/unit'

class TestBS < Test::Unit::TestCase

  def setup
    framework 'Foundation'
  end
  
  def test_boxed_classes
    # struct
    assert(NSRect.ancestors.include?(Boxed))
    assert('{_NSRect={_NSPoint=ff}{_NSSize=ff}}', NSRect.objc_type)
    assert_equal([:origin, :size] , NSRect.fields)
    assert(!NSRect.opaque?)

    # opaque
    assert(NSZone.ancestors.include?(Boxed))
    assert_equal('^{_NSZone=}', NSZone.objc_type)
    assert_equal([] , NSZone.fields)
    assert(NSZone.opaque?)
  end

  def test_opaque
    assert_raise(TypeError) { NSZone.new }
    z = 'foo'.zone
    assert_kind_of(NSZone, z)
    assert_equal(z, 'bar'.zone)
  end

  def test_struct1
    p = NSPoint.new
    assert_kind_of(NSPoint, p)
    assert_equal(0.0, p.x)
    assert_equal(0.0, p.y)
    assert_equal([0.0, 0.0], p.to_a)
    assert_equal(p, NSPoint.new)
    assert_equal(p, p.dup)
    assert_equal(p, p.clone)
    assert_equal(p, NSZeroPoint)

    p.x += 1
    assert_equal(1.0, p.x)
    assert_equal([1.0, 0.0], p.to_a)
    
    p2 = NSPoint.new(1.0, 2.0)
    assert_equal(p.x, p2.x)
    assert_not_equal(p.y, p2.y)
    p.y += 2
    assert_equal(p.y, p2.y)

    assert_raise(ArgumentError) { NSPoint.new(42) }
    assert_raise(ArgumentError) { NSPoint.new(42, 42, 42) }
    assert_raise(TypeError) { NSPoint.new(nil, nil) }
    assert_raise(ArgumentError) { NSPoint.new('foo', 'bar') }
    assert_raise(TypeError) { p.x = nil }
    assert_raise(ArgumentError) { p.x = 'foo' }

    r = NSRect.new
    assert_kind_of(NSRect, r)
    assert_equal(NSZeroPoint, r.origin)
    assert_equal(NSZeroSize, r.size) 
    assert_equal([NSZeroPoint, NSZeroSize], r.to_a)
    
    assert_raise(ArgumentError) { r.origin = nil }
    assert_raise(ArgumentError) { r.origin = 'foo' }

    r2 = NSRect.new(p, NSSize.new(42.0, 42.0))
    assert_not_equal(r, r2)
    r.size = NSSize.new(42.0, 42.0)
    assert_equal(r.size, r2.size)
    r.origin = p
    assert_equal(r.origin, r2.origin)
    assert_equal(r, r2)
    r.origin.x -= 1
    r2.origin.x -= 1
    r.size.width /= 2.0
    r2.size.width /= 2.0
    assert_equal(r, r2)
    assert_equal(r.to_a, r2.to_a)
  end

  def test_struct_nsstring_marshalling
    r = NSRange.new(1.0, 4.0)
    assert_kind_of(NSString, NSStringFromRange(r))
    # FIXME not passing yet 
    #assert_equal('{1.0, 4.0}', NSStringFromRange(r))
    assert_equal(r, NSRangeFromString(NSStringFromRange(r)))
    rect = NSRect.new(NSPoint.new(42.0, 1042.0), NSSize.new(123, 456))
    assert_equal(NSPoint.new(42.0, 1042.0),
      NSPointFromString(NSStringFromPoint(rect.origin)))
  end

end
