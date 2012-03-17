require File.expand_path("../setup", __FILE__)

describe "command execution" do
  include_context "acceptance"

  it "should execute and block a single command" do
    session.auth_by_password(acceptance_config["user"],
                             acceptance_config["password"])

    # Execute and build the result in this variable so we can check it later
    result = ""
    session.execute "echo foo" do |channel|
      channel.on_data { |d| result << d }
    end

    # The result should be what we asked for, since the above should block
    result.should == "foo\n"
  end
end
