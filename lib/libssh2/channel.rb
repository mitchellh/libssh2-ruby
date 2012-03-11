module LibSSH2
  # Represents a channel on top of an SSH session. Most communication
  # done via SSH is done on one or more channels. The actual communication
  # is then multiplexed onto a single connection.
  class Channel
    # This gives you access to the native underlying channel object.
    # Use this **at your own risk**. If you start calling native methods,
    # then the safety of the rest of this class is no longer guaranteed.
    #
    # @return [Native::Channel]
    attr_reader :native_channel

    # The session that this channel belongs to.
    #
    # @return [Session]
    attr_reader :session

    # Opens a new channel. This should almost never be called directly,
    # since the parameter required is the native channel object. Instead
    # use helpers such as {Session#open_channel}.
    #
    # @param [Native::Channel] native_channel Native channel structure.
    # @param [Socket] socket Open socket to communicate with.
    def initialize(native_channel, session)
      @native_channel = native_channel
      @session = session
    end

    # Executes the given command as if on the command line. This will
    # return immediately. Call `wait` on the channel to wait for the
    # channel to complete.
    #
    # @return [Process]
    def execute(command)
      @session.blocking_call do
        @native_channel.exec(command)
      end
    end

    # This blocks until the channel completes.
    def wait
      p @native_channel.eof
    end
  end
end
