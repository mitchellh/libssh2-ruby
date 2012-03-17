module LibSSH2
  # Represents a channel on top of an SSH session. Most communication
  # done via SSH is done on one or more channels. The actual communication
  # is then multiplexed onto a single connection.
  class Channel
    # The stream ID for the main data channel. This is always 0 as defined
    # by RFC 4254
    STREAM_DATA = 0

    # The stream ID for the extended data channel (typically used for stderr).
    # This is always 1 as defined by RFC 4254.
    STREAM_EXTENDED_DATA = 1

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
      @stream_callbacks = {}
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

    # Specify a callback that is called when data is received on this
    # channel.
    #
    # @yield [data] Called every time data is received, with the data.
    def on_data(&callback)
      @stream_callbacks[STREAM_DATA] = callback
    end

    # Specify a callback that is called when extended data (typically
    # stderr) is received on this channel.
    #
    # @yield [data] Called every time data is received, with the data.
    def on_extended_data(&callback)
      @stream_callbacks[STREAM_EXTENDED_DATA] = callback
    end

    # Specify a callback that is called when the exit status is
    # received on this channel.
    #
    # @yield [exit_status] Called once when the exit status is received with
    #   the exit status.
    def on_exit_status(&callback)
      @stream_callbacks[:exit_status] = callback
    end

    # Attempts reading from specific streams on the channel. This will not
    # block if data is unavailable. This typically doesn't need to be
    # called publicly but can be if you'd like. If data is found, it will
    # invoke the proper callback on the thread which calls this method.
    #
    # @return [Boolean] True if EOF is not seen, false if EOF is seen,
    #   meaning no data is ever coming again.
    def attempt_read
      # Return false if we have nothing else to read
      return false if @native_channel.eof

      # Attempt to read from stdout/stderr
      @session.blocking_call { read_stream(STREAM_DATA) }
      @session.blocking_call { read_stream(STREAM_EXTENDED_DATA) }

      # Return true always
      true
    end

    # This blocks until the channel completes, and also initiates the
    # event loop so that data callbacks will be called when data is
    # received. Prior to this, data will be received and buffered until
    # this is called. This ensures that callbacks are always called on
    # the thread that `wait` is called on.
    #
    # This method will also implicitly call {#close}.
    def wait
      # Read all the data
      loop { break if !attempt_read }

      # Close our end, we won't be sending any more requests.
      close if !closed?

      # Wait for the remote end to close
      @session.blocking_call { @native_channel.wait_closed }

      # Grab our exit status if we care about it
      exit_status_cb = @stream_callbacks[:exit_status]
      exit_status_cb.call(@native_channel.get_exit_status) if exit_status_cb
    end

    protected

    # This will read from the given stream ID and call the proper
    # callbacks if they exist.
    #
    # @param [Fixnum] stream_id The stream to read.
    def read_stream(stream_id)
      data_cb = @stream_callbacks[stream_id]

      while true
        data = nil
        begin
          data = @native_channel.read_ex(stream_id, 1000)
        rescue Native::Error::ERROR_EAGAIN
          # When we get an EAGAIN then we're done. Return.
          return
        end

        # If we got nil as a return value then there is no more data
        # to read.
        return if data.nil?

        # Callback if we have data to send and we have a callback
        data_cb.call(data) if data_cb
      end
    end
  end
end
