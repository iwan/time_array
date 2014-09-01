require 'active_support/core_ext/time/zones'

module TimeArray
  module ArrayExt
    module ClassMethods
      
    end
    
    module InstanceMethods
      def timed(start_time, options={})
        TimeArray.new(start_time, self, options)
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end

