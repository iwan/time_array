require 'spec_helper'

RSpec.describe 'operations' do
  subject(:a1) { TimeArray::TimeArray.new("2013", [2.1], unit: :year) }
  subject(:a2) { TimeArray::TimeArray.new("2013", [3.7], unit: :year) }

  it 'sum time arrays' do
    b = a1+a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1+3.7))

    c = a1+2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1+2))
  end

  it 'subtract time arrays' do
    b = a1-a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1-3.7))

    c = a1-2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1-2))
  end

  it 'multiply time arrays' do
    b = a1*a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1*3.7))

    c = a1*2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1*2))
  end

  it 'divide time arrays' do
    b = a1/a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1/3.7))

    c = a1/2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1/2))
  end

  it 'divide time arrays by zero' do
    a3 = TimeArray::TimeArray.new("2013", [1,0,1,1,1,1,1,1,1,1,1,1], unit: :month)
    c = a1/a3
    expect(c.size).to eq(8760)
    expect(c.sum).to eq(Float::INFINITY)
  end
end