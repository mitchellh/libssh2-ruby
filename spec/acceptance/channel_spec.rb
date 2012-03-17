require File.expand_path("../setup", __FILE__)

describe "channels" do
  include_context "acceptance"

  let(:authed_session) do
    session.auth_by_password(acceptance_config["user"],
                             acceptance_config["password"])
    session
  end

  let(:channel) { authed_session.open_channel }

  it "can't open a channel before authenticating" do
    expect { session.open_channel }.to
      raise_error(LibSSH2::AuthenticationRequired)
  end

  it "can open a channel once authenticated" do
    ch = authed_session.open_channel
    ch.should be_kind_of(LibSSH2::Channel)
  end

  it "can close a channel" do
    channel.close
    channel.should be_closed
  end

  it "can't close a channel twice" do
    channel.close
    expect { channel.close }.to raise_error(LibSSH2::DoubleCloseError)
  end

  it "can execute a command and read the output" do
    result = ""
    channel.execute "echo foo"
    channel.on_data { |d| result << d }
    channel.wait

    result.should == "foo\n"
  end

  it "can read the exit status" do
    status = nil
    channel.execute "exit 5"
    channel.on_exit_status { |value| status = value }
    channel.wait

    status.should == 5
  end
end
