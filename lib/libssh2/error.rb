module LibSSH2
  # The superclass of all errors that are thrown in LibSSH2
  class Error < StandardError; end

  # Error thrown when a method requires authentication before being
  # called.
  class AuthenticationRequired < Error; end

  # Thrown when {Channel#close} is called multiple times. Only _one_
  # CLOSE request may be sent over a channel.
  class DoubleCloseError < Error; end
end
