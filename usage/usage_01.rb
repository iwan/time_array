require_relative '../lib/time_array'


arr = TimeArray::TimeArray.new("2016-03", [1,2,3])
puts arr.start_time.to_s
puts arr.start_time.inspect

# puts Time.zone.parse("2014")
# puts Time.zone.parse("2020-01-02")