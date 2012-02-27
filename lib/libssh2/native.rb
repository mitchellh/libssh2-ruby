module LibSSH2
  # This module is almost completely implemented in pure C. Additional
  # methods are defined here to make things easier to implement.
  module Native
    # This is a helper to define proxy methods on this module. Many
    # methods are proxied to their respective objects, and this lets us
    # do it really easily, concisely.
    def self.proxy_method(*args)
      if args.length != 2 && args.length != 3
        raise ArgumentError, "2 or 3 arguments required."
      end

      prefix = nil
      prefix = args.shift if args.length == 3
      name   = args.shift
      klass  = args.shift
      method_name = name
      method_name = "#{prefix}_#{name}" if prefix

      metaclass = class << self; self; end
      metaclass.send(:define_method, method_name) do |object, *args|
        if !object.kind_of?(klass)
          raise ArgumentError, "Receiving object must be a: #{klass}"
        end

        object.send(name, *args)
      end
    end

    #----------------------------------------------------------------
    # Session Methods
    #----------------------------------------------------------------
    def self.session_init
      Native::Session.new
    end

    proxy_method :session, :set_blocking, Native::Session
    proxy_method :session, :handshake, Native::Session
    proxy_method :userauth_password, Native::Session

    #----------------------------------------------------------------
    # Channel Methods
    #----------------------------------------------------------------
    def self.channel_open_session(session)
      Native::Channel.new(session)
    end

    proxy_method :channel, :exec, Native::Channel
  end
end
