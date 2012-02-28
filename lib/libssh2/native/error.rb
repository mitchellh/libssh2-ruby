require "libssh2/error"
require "libssh2/native/error_codes"

module LibSSH2
  module Native
    module Error
      # Returns an error class for the given numeric code. If no such error
      # class exists, then the generic class will be returned.
      def self.error_for_code(code)
        const_get(LIBSSH_ERRORS_BY_CODE[code])
      end

      # The generic error that is the superclass for all the more specific
      # errors that libssh2 might throw.
      class Generic < LibSSH2::Error
        # The numeric error code for an instance.
        attr_reader :error_code

        # Create a generic error.
        #
        # @param [Fixnum] error_code The error code of the error.
        def initialize(error_code)
          @error_code = error_code
        end

        def to_s
          "Error: #{LIBSSH_ERRORS_BY_CODE[@error_code]} (#{@error_code})"
        end
      end

      # Define the error classes for every error we know about.
      LIBSSH_ERRORS_BY_KEY.each do |key, code|
        const_set(key, Class.new(Generic))
      end
    end
  end
end
