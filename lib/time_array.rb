%w(
  version
  vector
  exceptions
  time_array
  hour_array
  array_ext
  units
  group_hash
  compactor
).each { |file| require File.join(File.dirname(__FILE__), 'time_array', file) }


class Array
  include TimeArray::ArrayExt
end

