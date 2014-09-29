require_relative '../lib/time_array'


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