require 'spec_helper'

RSpec.describe 'time array' do
  subject(:a1) { TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome", unit: :hour) }
  values = [1,2,3]


  it 'init' do
    expect(a1).to be_an_instance_of(TimeArray::TimeArray)
    expect(a1.v).to be_an_instance_of(TimeArray::Vector)
  end

  it 'unit option on initialize' do
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: :hour).unit).to eq(:hour)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome", unit: :hour).unit).to eq(:hour)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'hour').unit).to eq(:hour)
    expect(TimeArray::TimeArray.new("2013").unit).to eq(:hour)

    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'month').unit).to eq(:month)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'year').unit).to eq(:year)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'day').unit).to eq(:day)

    expect{ TimeArray::TimeArray.new("2013", [1,2,3], unit: 'foo').unit}.to raise_error(ArgumentError)
  end

  it 'zone opt on initialize' do
    expect(a1.zone).to eq("Rome")
    expect(TimeArray::TimeArray.new("2013", [1,2,3]).zone).to eq("Rome")
    expect(TimeArray::TimeArray.new("2013", [1,2,3], zone: "London").zone).to eq("London")
    expect(a1.time_zone).to be_an_instance_of(ActiveSupport::TimeZone)
  end

  it 'start_time on initialize' do
    expect(TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-01-01 00:00:00 +0100")
    expect(TimeArray::TimeArray.new("2013-03", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-03-01 00:00:00 +0100")
    expect(TimeArray::TimeArray.new("2013-03-04", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-03-04 00:00:00 +0100")
    expect(TimeArray::TimeArray.new("2013-03-04 13", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-03-04 13:00:00 +0100")
    expect{TimeArray::TimeArray.new("foobar", [1,2,3], zone: "Rome").start_time.to_s}.to raise_error(ArgumentError)
  end

  it 'clone' do
    orig = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome")
    cloned = orig.clone
    expect(orig.start_time).to equal(orig.start_time)
    expect(cloned.start_time).not_to equal(orig.start_time)
    expect(cloned.v).not_to equal(orig.v)
    # expect(cloned.time_zone).not_to equal(orig.time_zone) # why?
    
  end

  it 'set all values to' do
    x = 3.4
    expect(a1.all_to(x).v).to eq(Array.new(a1.size, x))
  end

  it 'get values size' do
    expect(a1.size).to eq(3)
    expect(TimeArray::TimeArray.new("2013").size).to eq(0)
  end

  it 'sum of values' do
    time_arr = TimeArray::TimeArray.new("2013", [0,1,2,-3,0,2,-1])
    expect(time_arr.sum).to eq(1)
    expect(time_arr.sum).to eq(1.0)
    expect(time_arr.sum(values: :all)).to eq(1)
    expect(time_arr.sum(values: 'all')).to eq(1)
    expect(time_arr.sum(values: :non_zero)).to eq(1)

    expect(time_arr.sum(values: :positive)).to eq(5)
    expect(time_arr.sum(values: :non_positive)).to eq(-4)
    expect(time_arr.sum(values: :negative)).to eq(-4)
    expect(time_arr.sum(values: :non_negative)).to eq(5)
    expect(time_arr.sum(values: :zero)).to eq(0)
    expect{time_arr.sum(values: :invalid_argument)}.to raise_error(ArgumentError)
  end

  it 'count of values' do
    time_arr = TimeArray::TimeArray.new("2013", [0,1,2,-3,0,2,-1])
    expect(time_arr.count).to eq(7)
    expect(time_arr.count).to eq(7.0)
    expect(time_arr.count(values: :all)).to eq(7)
    expect(time_arr.count(values: 'all')).to eq(7)

    expect(time_arr.count(values: :positive)).to eq(3)
    expect(time_arr.count(values: :non_positive)).to eq(4)
    expect(time_arr.count(values: :negative)).to eq(2)
    expect(time_arr.count(values: :non_negative)).to eq(5)
    expect(time_arr.count(values: :zero)).to eq(2)
    expect(time_arr.count(values: :non_zero)).to eq(5)
    expect{time_arr.count(values: :invalid_argument)}.to raise_error(ArgumentError)
  end

  it 'average of values' do
    time_arr = TimeArray::TimeArray.new("2013", [0,1,2,-3,0,2,-1])
    expect(time_arr.avg).to eq(1.0/7)
    expect(time_arr.avg(values: :positive)).to eq(5.0/3)
    expect(time_arr.avg(values: :non_positive)).to eq(-1.0)
    expect(time_arr.avg(values: :negative)).to eq(-2.0)
    expect(time_arr.avg(values: :non_negative)).to eq(1.0)
    expect(time_arr.avg(values: :zero)).to eq(0.0)
    expect{time_arr.avg(values: :invalid_argument)}.to raise_error(ArgumentError)

    expect(TimeArray::TimeArray.new("2013", [0,1,2,3,0,2,1]).avg(values: :negative)).to be_nil
  end
end