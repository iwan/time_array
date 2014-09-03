require 'spec_helper'

RSpec.describe 'time array' do
  subject(:a1) { TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome", unit: :hour) }
  values = [1,2,3]
  subject(:v1) { [0,1,2,-3,0,2,-1] }
  subject(:time_arr) { TimeArray::TimeArray.new("2013", v1) }


  it 'init' do
    expect(a1).to be_an_instance_of(TimeArray::TimeArray)
    expect(a1.v).to be_an_instance_of(TimeArray::Vector)

    expect(TimeArray::TimeArray.new("2013", [1], unit: :year).v.size).to eq(8760)
    expect(TimeArray::TimeArray.new("2012", [1], unit: :year).v.size).to eq(8760+24) # lead year
    expect(TimeArray::TimeArray.new("2013", [1], unit: :month).v.size).to eq(31*24)
    expect(TimeArray::TimeArray.new("2013", [1], unit: :day).v.size).to eq(24)
    expect(TimeArray::TimeArray.new("2013", [1], unit: :hour).v.size).to eq(1)

    expect(TimeArray::TimeArray.new("2013-04-16", [1], unit: :year).v.size).to eq(8760)
    expect(TimeArray::TimeArray.new("2013-04-16", [1], unit: :month).v.size).to eq(30*24)
    expect(TimeArray::TimeArray.new("2013-04-16", [1], unit: :day).v.size).to eq(24)
    expect(TimeArray::TimeArray.new("2013-04-16", [1], unit: :hour).v.size).to eq(1)
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
    expect(time_arr.avg).to eq(1.0/7)
    expect(time_arr.avg(values: :positive)).to eq(5.0/3)
    expect(time_arr.avg(values: :non_positive)).to eq(-1.0)
    expect(time_arr.avg(values: :negative)).to eq(-2.0)
    expect(time_arr.avg(values: :non_negative)).to eq(1.0)
    expect(time_arr.avg(values: :zero)).to eq(0.0)
    expect{time_arr.avg(values: :invalid_argument)}.to raise_error(ArgumentError)

    expect(TimeArray::TimeArray.new("2013", [0,1,2,3,0,2,1]).avg(values: :negative)).to be_nil
  end

  it 'minimum and maximum values' do
    expect(time_arr.min).to eq(-3)
    expect(time_arr.max).to eq(2)
    expect(TimeArray::TimeArray.new("2013", []).max).to be_nil
    expect(TimeArray::TimeArray.new("2013", []).min).to be_nil
  end

  it 'round values' do
    expect(TimeArray::TimeArray.new("2013", [0.0, 1.23456, nil]).round!(2).v).to eq([0.0, 1.23, nil])
    expect(TimeArray::TimeArray.new("2013", [0.0, 1.23456, nil]).round!(2).v).to be_an_instance_of(TimeArray::Vector)
  end

  it 'empty' do
    expect(time_arr.empty?).to eq(false)
    expect(TimeArray::TimeArray.new("2013", []).empty?).to eq(true)
  end

  it 'end time' do
    st = time_arr.start_time
    expect(time_arr.end_time).to eq(st+(v1.size-1).hours)
  end

  it 'clear data' do
    expect(time_arr.clear_data.empty?).to eq(true)
  end

  it 'aligned with' do
    a2 = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome")
    expect(a2.aligned_with?(TimeArray::TimeArray.new("2013", [0,3,0], zone: "Rome"))).to eq(true)
    expect(a2.aligned_with?(TimeArray::TimeArray.new("2013", [0,3], zone: "Rome"))).to eq(false)
    expect(a2.aligned_with?(TimeArray::TimeArray.new("2013", [0,3,4], zone: "London"))).to eq(false)
    expect(a2.aligned_with?(TimeArray::TimeArray.new("2012", [0,3,4], zone: "Rome"))).to eq(false)
  end

  it 'align with' do
    # case 1. Different data size
    a2 = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome")
    a3 = TimeArray::TimeArray.new("2013", [4,5], zone: "Rome")
    expect(a2.align_with(a3).v).to eq([1,2])
    a3 = TimeArray::TimeArray.new("2013", [], zone: "Rome")
    expect(a2.align_with(a3).v).to eq([])

    # case 2. Different zone
    a2 = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome")
    a3 = TimeArray::TimeArray.new("2013", [4,5,6], zone: "London")
    expect(a2.align_with(a3).v).to eq([2,3])
    a2 = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome")
    expect(a3.align_with(a2).v).to eq([4,5])

    a2 = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome", unit: :day)
    a3 = TimeArray::TimeArray.new("2013", [4,5,6], zone: "London", unit: :day)
    expect(a2.align_with(a3).size).to eq(24*3-1)

    # case 2. Different start time (and zone and size)
    a2 = TimeArray::TimeArray.new("2013-03-04 13", [1,2,3,4,5], zone: "Rome")
    a3 = TimeArray::TimeArray.new("2013-03-04 14", [4,5], zone: "London")
    expect(a2.align_with(a3).v).to eq([3,4])
  end

  it 'print values' do
    a2 = TimeArray::TimeArray.new("2013-03-04 13", [1,2,3], zone: "Rome")
    aa = a2.print_values.split("\n")
    expect(aa.first.split("\t")).to eq(["2013-03-04 13:00 Mon", "1"])
  end

  it 'fill until the end of the year' do
    a2 = TimeArray::TimeArray.new("2013-02", [10,20,30])
    value = 1
    a2.until_the_end_of_the_year(value)
    size = 8760 - 31*24
    sum = size*value -3 + 10+20+30
    expect(a2.size).to eq(size)
    expect(a2.sum).to eq(sum)
  end

  it 'get value at' do
    expect(a1.value(0)).to eq(1)
    expect(a1.value(1)).to eq(2)
    expect(a1.value(2)).to eq(3)
    expect(a1.value(20)).to be_nil # out of range!
  end


  it 'set value at' do
    a1.set_value(0, 100)
    a1.set_value(2, 234)
    expect(a1.v).to eq([100,2,234])
    a1.set_value(20, 3) # out of range!
    expect(a1.v).to eq([100,2,234])
  end

  it 'get first x values' do
    arr = Array.new(100){|i| rand(1000)}
    a = TimeArray::TimeArray.new("2013", arr, zone: "Rome", unit: :hour)
    expect(a.first_values(23)).to eq(arr[0...23])
  end
end