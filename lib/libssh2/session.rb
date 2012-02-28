require "socket"

module LibSSH2
  # Represents a session, or a connection for SSH.
  class Session
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
      @session = Native.session_init
      @session.set_blocking(true)
      @session.handshake(@socket.fileno)
    end

    # Returns a boolean denoting whether this session has been authenticated
    # yet or not.
    #
    # @return [TrueClass, FalseClass]
    def authenticated?
      @session.userauth_authenticated
    end

    # Authenticates using a username and password. This will return true
    # or false representing whether the authentication succeeding or not.
    #
    # @return [TrueClass, FalseClass]
    def auth_by_password(username, password)
      @session.userauth_password(username, password)
    end
  end
end
