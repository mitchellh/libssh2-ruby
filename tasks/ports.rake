require "mini_portile"
require "rake/extensioncompiler"

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

# We need to patch the cross compilation task to compile our
# ports prior to building.
task :cross do
  host = ENV.fetch("HOST", Rake::ExtensionCompiler.mingw_host)
  $recipes.each do |_, recipe|
    recipe.host = host
  end

  # Make sure the port is compiled before cross compilation
  Rake::Task["compile"].prerequisites.unshift "ports:libssh2"
end
