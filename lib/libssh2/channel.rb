module LibSSH2
  # Represents a channel on top of an SSH session. Most communication
  # done via SSH is done on one or more channels. The actual communication
  # is then multiplexed onto a single connection.
  class Channel
    # Opens a new channel. This should almost never be called directly,
    # since the parameter required is the native channel object. Instead
    # use helpers such as {Session#open_channel}.
    #
    # @param [Native::Channel] native_channel Native channel structure.
    # @param [Socket] socket Open socket to communicate with.
    def initialize(native_channel, socket)
      @channel = native_channel
      @socket  = socket
    end
  end
end
