require File.expand_path("../setup", __FILE__)

describe "authentication" do
  include_context "acceptance"

  it "should not be authenticated by default" do
    session.should_not be_authenticated
  end

  describe "by password" do
    it "should authenticate" do
      session.auth_by_password(acceptance_config["user"],
                             acceptance_config["password"])

      session.should be_authenticated
    end

    it "should be able to fail" do
      expect {
        session.auth_by_password(acceptance_config["user"] + "_wrong", "wrong")
      }.to raise_error(LibSSH2::Native::Error::ERROR_PUBLICKEY_UNRECOGNIZED)

      session.should_not be_authenticated
    end
  end

  describe "by keypair" do
    it "should authentiate" do
      session.auth_by_publickey_fromfile(acceptance_config["user"],
                                         acceptance_config["public_key_path"],
                                         acceptance_config["private_key_path"])

      session.should be_authenticated
    end

    it "should be able to fail" do
      pending "Need a fake keypair."
    end
  end
end
