require 'active_support/core_ext/time/zones'

module TimeArray
  module TimeExt
    
    module InstanceMethods
      # has year changed in last hour?
      def year_changed?
        self.year != (self-1.hour).year
      end

      # has year changed in last month?
      def month_changed?
        self.month != (self-1.hour).month
      end

      # has year changed in last day?
      def day_changed?
        self.day != (self-1.hour).day
      end
    end
    
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end