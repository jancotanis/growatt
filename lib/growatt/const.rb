
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
    YEAR = 3
  end

  class Inverter
    ON = "0101"
    OFF = "0000"
  end

  class ExportLimit
    DISABLE = -1
    WATT = 1
    PERCENTAGE = 0
  end

end
