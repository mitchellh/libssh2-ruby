require "libssh2/native/error_codes"

module LibSSH2
  module Native
    # The exception raised if anything erroneous occurs.
    class Error < StandardError
      attr_reader :error_code

      def to_s
        "Error: #{LIBSSH_ERRORS_BY_CODE[@error_code]} (#{@error_code})"
      end
    end
  end
end
