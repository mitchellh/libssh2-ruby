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
    # @param [Session] session Session that this channel belongs to.
    def initialize(native_channel, session)
      @native_channel = native_channel
      @session        = session
      @closed         = false
      @exit_status    = nil
    end

    # Sends a CLOSE request to the remote end, which signals that we will
    # not send any more data. Note that the remote end may continue sending
    # data until it sends its own respective CLOSE request.
    def close
      # Only one CLOSE request may be sent. Guard your close calls by
      # checking the value of {#closed?}
      raise DoubleCloseError if @closed

      # Send the CLOSE
      @session.blocking_call { @native_channel.close }

      # Mark that we closed
      @closed = true
    end

    # Returns a boolean of whether we closed or not. Note that this is
    # not an indicator of the remote end has closed the connection.
    #
    # @return [Boolean]
    def closed?
      @closed
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

    # This blocks until the channel completes. This will implicitly
    # call {#close} as well, since the channel can only complete if it
    # is closed.
    def wait
      while !@native_channel.eof
        p @session.blocking_call { @native_channel.read(1000) }
      end

      # Close our end, we won't be sending any more requests.
      close if !closed?

      # Wait for the remote end to close
      @session.blocking_call { @native_channel.wait_closed }

      # Grab our exit status
      @exit_status = @native_channel.get_exit_status
    end
  end
end
