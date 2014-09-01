%w(
  version
  vector
  time_array
  hour_array
  array_ext
  units
).each { |file| require File.join(File.dirname(__FILE__), 'time_array', file) }


class Array
  include TimeArray::ArrayExt
end

