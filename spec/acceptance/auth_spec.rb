require File.expand_path("../setup", __FILE__)

describe "authentication" do
  include_context "acceptance"

  it "should not be authenticated by default" do
    session.should_not be_authenticated
  end

  it "should authenticate by password" do
    session.auth_by_password(acceptance_config["user"],
                             acceptance_config["password"])

    session.should be_authenticated
  end

  it "should be able to fail authentication by password" do
    expect {
      session.auth_by_password(acceptance_config["user"] + "_wrong", "wrong")
    }.to raise_error(LibSSH2::Native::Error::ERROR_PUBLICKEY_UNRECOGNIZED)

    session.should_not be_authenticated
  end
end
