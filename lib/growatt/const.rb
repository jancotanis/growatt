# frozen_string_literal: true

module Growatt
  # A base class for defining enumerations using constants.
  #
  # This class dynamically defines constants from an array of strings.
  class Enum
    # Defines constants based on the provided array.
    #
    # @param array [Array<String>] The array of strings to be converted into constants.
    def self.enum(array)
      array.each do |c|
        const_set c, c
      end
    end
  end

  # Represents different timespan options for data retrieval.
  class Timespan
    # Hourly data timespan
    HOUR = 0
    # Daily data timespan
    DAY = 1
    # Monthly data timespan
    MONTH = 2
    # Yearly data timespan
    YEAR = 3
  end

  # Represents possible states for an inverter.
  class Inverter
    # Inverter is turned on
    ON = "0101"
    # Inverter is turned off
    OFF = "0000"
  end

  # Represents export limit settings for an inverter.
  class ExportLimit
    # Disables export limitation
    DISABLE = -1
    # Export limit is set in watts
    WATT = 1
    # Export limit is set in percentage
    PERCENTAGE = 0
  end
end
