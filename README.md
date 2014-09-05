# TimeArray

[![Build Status](https://travis-ci.org/iwan/time_array.png)](https://travis-ci.org/iwan/time_array)
[![Coverage Status](https://img.shields.io/coveralls/iwan/time_array.svg)](https://coveralls.io/r/iwan/time_array)
[![Code Climate](https://codeclimate.com/github/iwan/time_array/badges/gpa.svg)](https://codeclimate.com/github/iwan/time_array)
Define a tool (a class) to deal with time-related arrays: sums, multiplications, and so on.

## Installation

Add this line to your application's Gemfile:

    gem 'time_array'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install time_array

## Usage

```ruby
include TimeArray

time_arr = TimeArray::TimeArray.new("2014", [2.3], unit: :year)
```
Generate a time-related array: 8760 elements of '2.3' values, one for each hour in the year 2014.

You can do the same starting from a standard Array:
```ruby
[2.3].timed("2014", unit: :year)
```



In detail:
```ruby
time_arr = [1,2,3.14,4,5].timed("2014")
```
Instance a structure like this:

| Time with zone            | Value |
|---------------------------|------:|
| 2014-01-01 00:00:00 +0100 |     1 |
| 2014-01-01 01:00:00 +0100 |     2 |
| 2014-01-01 02:00:00 +0100 |  3.14 |
| 2014-01-01 03:00:00 +0100 |     4 |
| 2014-03-01 04:00:00 +0100 |     5 |



By default the unit of data you pass is hourly, but you can specify different units: day, month or year. The internal representation of data is always hourly. So your daily data is converted to hourly data.

```ruby
time_arr = [1,2,3].timed("2014", unit: :day)
time_arr.size   # => 24*3
```

The other option you can specify is the time zone (by default is 'Rome'), TimeArray use ActiveSupport::TimeWithZone to store the time data.

```ruby
time_arr = [1,2,3].timed("2014", zone: "Rome")
time_arr.size   # => 3
```

### Operations

```ruby
a = [12].timed("2014", unit: :year)
b = [4].timed("2014", unit: :year)
a+b   # => will be an array of [16,16,16,...], size of 8760
a-b   # => will be an array of [8,8,8,...], size of 8760
a*b   # => will be an array of [48,48,48,...], size of 8760
a/b   # => will be an array of [3,3,3,...], size of 8760
```
If you sum two arrays that are not aligned (in term of time), the result of the operation will be applied to the intersection of the two arrays:

```ruby
a = [12].timed("2014", unit: :day)  # size of 24
b = [4, 3].timed("2014", unit: :day)  # size of 48
a.aligned_with? b   # => false
a+b   # => will be an array of [16,16,16,...], size of 24
```
The same goes for time_arrays defined in two different time zones:

```ruby
a = [1,2,3,4,5].timed("2014", zone: "Rome")
b = [1,2,3].timed("2014", zone: "London")
a.aligned_with? b   # => false
a+b   # => [3,5,7]
```


## Contributing

1. Fork it ( https://github.com/iwan/time_array/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
