require "libssh2"

shared_context "acceptance" do
  let(:acceptance_config) do
    # If we don't have test configuration, then throw an error
    if !$spec_config
      raise "A config.yml must be present in the spec directory. See the example."
    end

    # Return the actual acceptance-only config
    $spec_config["acceptance"]
  end

  let(:session) do
    # Return a session connected to our configured host/port
    LibSSH2::Session.new(acceptance_config["host"], acceptance_config["port"])
  end
end
