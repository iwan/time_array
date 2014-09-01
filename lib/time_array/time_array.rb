require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/hash'


module TimeArray
  class TimeArray
    attr_reader :start_time, :v, :unit

    def initialize(start_time, values=[], options={})
      manage_options(options)
      set_start_time start_time
      set_values     values      
    end


    def zone
      Time.zone.name
    end

    def time_zone
      Time.zone
    end

    def clone
      TimeArray.new(@start_time, (@v.clone rescue Vector.new), zone: Time.zone.name)
    end

    def all_to(new_value)
      @v.map{|e| e=new_value}
    end

    private

    def set_values(data)
      # the values are always stored as hour values
      if unit==:hour
        @v = Vector.new(data)
      else
        start_time = (@start_time.nil? ? nil : @start_time.clone)
        @v = Vector.new(data.size)

        prev_value = start_time.send(@unit)
        data.each do |v|
          while start_time.send(@unit)==prev_value
            @v << v
            start_time+=1.hour
          end
          prev_value = start_time.send(unit)
        end
      end

    end

    def set_start_time(start_time)
      st = read_start_time(start_time)
      @start_time = floor_start_time(st, @unit)
    end


    def read_start_time(start_time)
      # start_time = Time.zone.now if start_time.nil? # ====
      if start_time.is_a?(String)
        start_time.gsub!("/", "-")
        begin
          start_time = Time.zone.parse(start_time)
        rescue Exception => e
          case start_time.size
          when 4
            start_time = Time.zone.parse("#{start_time}-01-01")
          when 7
            start_time = Time.zone.parse("#{start_time}-01")
          else
            raise ArgumentError, "Start time not valid"
          end
        end
      end
      start_time
    end

    def floor_start_time(t, unit=:hour)
      return nil if t.nil?
      case @unit
      # when :'15minutes'
      #   t = t - t.sec - (60 * (t.min % 15)) # floor to hour
      when :hour
        t = Time.zone.parse("#{t.year}-#{t.month}-#{t.day} #{t.hour}:00:00")
        # t = t - t.sec - (60 * (t.min % 60)) # floor to hour
      when :day
        t = Time.zone.parse("#{t.year}-#{t.month}-#{t.day}")
      when :month
        t = Time.zone.parse("#{t.year}-#{t.month}-01")
      when :year
        t = Time.zone.parse("#{t.year}-01-01")
      end
      t
    end



    def manage_options(options)
      options = options.symbolize_keys.assert_valid_keys(:unit, :zone)

      # unit
      options = {unit: :hour}.merge(options)
      @unit = options[:unit].to_sym
      Units.validate(@unit)

      # zone
      Time.zone = options[:zone] || "Rome"
    end
  end
end

