require_relative '../lib/time_array'

if false
  arr = TimeArray::TimeArray.new("2016-03", [1,2,3])
  puts arr.start_time.to_s
  puts arr.start_time.class
  puts arr.start_time.inspect

  # puts Time.zone.parse("2014")
  # puts Time.zone.parse("2020-01-02")

  a = [2,3,4].timed("2012", unit: :day)
  puts a.size
  puts a.v.inspect


  puts [1,2,3].timed("2014", unit: :day).size

  puts arr.group_by(:day)
  puts arr.group_by(:hour)


  puts arr.start_time.strftime("%Y-%m-%d %H:%M")

end

if true
  ta = TimeArray::TimeArray.new("2015", [1,2,2,2,2,2,2,2,2,2,2,2], unit: :month)
  # puts ta.v.inspect
  ta2 = ta.compact
  puts ta2.v.inspect
  puts ta2.inspect # TimeArray::Compact

end

if true
  interval = :month
  start_time = Time.new(2015,1,1)
  array = [1,2,2,2,2,2,2,2,2,2,2,2]
  ta1 = array.timed(start_time, unit: interval)
  # puts ta1
  ta2 = ta1.compact
  puts ta2.inspect
  puts ta2
end

