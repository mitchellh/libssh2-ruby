require "mini_portile"

libssh2_version = "1.4.0"
$recipes = {}
$recipes[:libssh2] = MiniPortile.new("libssh2", libssh2_version)
$recipes[:libssh2].files << "http://www.libssh2.org/download/libssh2-#{libssh2_version}.tar.gz"

namespace :ports do
  directory "ports"

  desc "Compile libssh2"
  task :libssh2 => "ports" do
    recipe = $recipes[:libssh2]

    checkpoint = "ports/.#{recipe.name}.#{recipe.version}.#{recipe.host}.timestamp"
    if !File.exist?(checkpoint)
      recipe.cook
      touch checkpoint
    end

    recipe.activate
  end
end
