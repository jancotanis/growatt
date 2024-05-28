module Growatt

  # Generic error to be able to rescue all Hudu errors
  class GrowattError < StandardError; end

  # Configuration returns error
  class ConfigurationError < GrowattError; end

  # Issue authenticting
  class AuthenticationError < GrowattError; end

end
