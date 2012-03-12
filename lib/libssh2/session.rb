require "socket"

require "libssh2/channel"
require "libssh2/error"

module LibSSH2
  # Represents a session, or a connection to a remote host for SSH.
  class Session
    # This gives you access to the native underlying session object.
    # This should be used at **your own risk**. If you start calling
    # native methods, the safety of the rest of this class is not
    # guaranteed.
    #
    # @return [Native::Session]
    attr_reader :native_session

    # Initializes a new session for the given host and port. This will
    # open a connection with the remote host.
    #
    # @param [String] host Hostname or IP of the remote host.
    # @param [Fixnum] port Port on the host to connect to.
    def initialize(host, port)
      @host = host
      @port = port

      # Connect to the remote host
      @socket  = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      @socket.connect(Socket.sockaddr_in(@port, @host))

      # Create the underlying LibSSH2 structures
      @native_session = Native.session_init
      @native_session.set_blocking(false)
      blocking_call { @native_session.handshake(@socket.fileno) }
    end

    # Returns a boolean denoting whether this session has been authenticated
    # yet or not.
    #
    # @return [Boolean]
    def authenticated?
      @native_session.userauth_authenticated
    end

    # Authenticates using a username and password. This will return true if
    # it succeeds or throw an exception if it doesn't. The reason an exception
    # is thrown instead of a basic "false" is because there can be many reasons
    # why authentication fails, and exceptions allow us to be more specific about
    # what went wrong.
    #
    # @param [String] username Username to authentiate with.
    # @param [String] password Associated password for the username.
    # @return True
    def auth_by_password(username, password)
      blocking_call { @native_session.userauth_password(username, password) }
    end

    # Authenticates using public key authentication. This will return true if
    # authentication was successful or throw an exception if it wasn't. The reason
    # an exception is thrown instead of a basic "false" is becuse there can be
    # many reasons why authentication fails, and exceptions allow us to be more specific
    # about what went wrong.
    #
    # @param [String] username Username to authenticate as.
    # @param [String] pubkey_path Path to the public key. This must be fully expanded.
    # @param [String] privatekey_path Path to the private key. This must be
    #   fully expanded.
    # @param [optional, password] Password for the private key.
    # @return True
    def auth_by_publickey_fromfile(username, pubkey_path, privatekey_path, password=nil)
      blocking_call do
        @native_session.userauth_publickey_fromfile(
          username, pubkey_path, privatekey_path, password)
      end
    end

    # Performs the given block until it doesn't raise ERROR_EAGAIN. ERROR_EAGAIN
    # is raised by libssh2 when a call would black and the session is non-blocking.
    # This method forces the non-blocking calls to block until they complete.
    #
    # **Note:** You should almost never have to call this on your own, but is
    # available should you need to execute a native method.
    #
    # @yield [] Called until ERROR_EAGAIN is not raised, returns the value.
    # @return [Object] Returns the value the block returns.
    def blocking_call
      while true
        begin
          return yield
        rescue Native::Error::ERROR_EAGAIN
          waitsocket
        end
      end
    end

    # Convenience method to execute a command with this session. This will
    # open a new channel and yield the channel to a block so that data listeners
    # can be attached to it, if needed. The channel is also returned.
    #
    # @param [String] command Command to execute
    # @yield [channel] Called with the opened channel prior to executing so
    #   that data listeners can be attached.
    # @return [Channel]
    def execute(command, &block)
      channel = open_channel(&block)
      channel.execute(command)
      channel.wait
      channel
    end

     # Opens a new channel and returns a {Channel} object.
    #
    # @yield [channel] Optional, if a block is given, the resulting channel is
    #   yielded to it prior to returning.
    # @return [Channel]
    def open_channel
      # We need to check if we're authenticated here otherwise the next call
      # will actually block forever.
      raise AuthenticationRequired if !authenticated?

      # Open a new channel and return it
      native_channel = Native::Channel.new(@native_session)
      result = Channel.new(native_channel, self)
      yield result if block_given?
      result
    end

    # If an ERROR_EGAIN error is raised by libssh2 then this should be called
    # to wait for the socket to be ready to use again.
    def waitsocket
      readfd  = []
      writefd = []

      # Determine which direction to wait for...
      dir = @native_session.block_directions
      readfd  << @socket if dir & Native::SESSION_BLOCK_INBOUND
      writefd << @socket if dir & Native::SESSION_BLOCK_OUTBOUND

      # Select on the file descriptors
      IO.select(readfd, writefd, nil, 10)
    end
  end
end
