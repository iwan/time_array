require 'spec_helper'

RSpec.describe 'hour array counts' do
  # subject(:v1) { Array.new([0,1,-2,5,-7,11,-13]) }
  # subject(:v2) { Array.new([1,7,19,31,-13,5,-2]) }
  v1 = [0,1,-2,5,-7,11,-13]
  v2 = [1,7,19,31,-13,5,-2]
  v12 = v1.map.with_index{|e,i| v1[i]+v2[i]}
  ta1 = TimeArray::TimeArray.new("2013", v1)
  ta2 = TimeArray::TimeArray.new("2013", v2)
  ta12 = TimeArray::TimeArray.new("2013", v12)

  it 'sum all elements' do
    # expect((ta1.sum(ta2)).v).to eq(ta12.v)
    # expect(ta1.v).to eq(v1)
  end
end