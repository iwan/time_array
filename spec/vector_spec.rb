require 'spec_helper'

RSpec.describe 'vector' do
  subject(:v1) { TimeArray::Vector.new([0,1,2,-3,0,2,-1]) }

  it 'sum all elements' do
    expect(v1.sum_all).to eq(1)
  end

  it 'sum positive elements' do
    expect(v1.sum_positive).to eq(5)
  end

  it 'sum negative elements' do
    expect(v1.sum_negative).to eq(-4)
  end


  it 'count pos elements' do
    expect(v1.count_positive).to eq(3)
  end

  it 'count non pos elements' do
    expect(v1.count_non_positive).to eq(4)
  end

  it 'count neg elements' do
    expect(v1.count_negative).to eq(2)
  end

  it 'count non neg elements' do
    expect(v1.count_non_negative).to eq(5)
  end

  it 'count zero elements' do
    expect(v1.count_zero).to eq(2)
  end

  it 'count non zero elements' do
    expect(v1.count_non_zero).to eq(5)
  end

  it 'count zero elements' do
    expect(v1.count_all).to eq(7)
  end

  it 'clone' do
    expect(v1.clone).not_to equal(v1)
    expect(v1.clone).to eq(v1)
  end

  it 'sum vectors' do
    v2 = TimeArray::Vector.new([0,1,2,-3,0,2,-1])
    expect(v1+v2).to be_an_instance_of(TimeArray::Vector)
  end
end