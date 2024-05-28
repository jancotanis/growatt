
module Growatt
  class Enum
      def self.enum(array)
        array.each do |c|
          const_set c,c
        end
      end
  end
  class Timespan
    HOUR = 0
    DAY = 1
    MONTH = 2
  end
  class Inverter
    ON = "0101"
    OFF = "0000"
  end
end
