require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	test "listify nothing" do
	   assert_equal 'none', listify( [] ), 'empty list is not listifyable'
	end
	test "listify one" do
	   assert_equal 'lipsum', listify( ['lipsum'] ), 'single item list is not listifyable'
	end
	test "listify two" do
	   assert_equal 'lipsum and dolor', listify( ['lipsum', 'dolor'] ), 'two items should be joined by and'
	end
	test "listify three" do
	   assert_equal 'lipsum, dolor and sit', listify( ['lipsum', 'dolor', 'sit'] ), 'three items a b c should be like a, b and c'
	end
	test "listify more" do
	   assert_equal 'lipsum, dolor, sit and amet', listify( ['lipsum', 'dolor', 'sit', 'amet'] ), 'more than three items a...n should be like a, a+1, ..., n-1 and n'
	end
	
	test "filter_on_key" do
		#results = [ {:key => 0 }, {:key => 1} ]
		#assert_equal [ results.at(0) ], filter_on_key( results, :key, 0 ), 'should have filtered on key'
		#assert_equal [ results.at(1) ], filter_on_key( results, :key, 1 ), 'should have filtered on key'
		#assert_equal 2, results.count, 'should not have edited original'
	end
	
	test "filter_on_key!" do
		#results = [ {:key => 0 }, {:key => 1} ]
		#filter_on_key!( results, :key, 0 )
		#assert_equal 1, results.count, 'should have edited original'
		#assert_equal 0, results.at(0)[:key], 'should have filtered on key'
	end
end
