require "mini_portile"
require "rake/extensioncompiler"

libssh2_version = "1.4.0"
openssl_version = "1.0.1"

$recipes = {}
$recipes[:libssh2] = MiniPortile.new("libssh2", libssh2_version)
$recipes[:openssl] = MiniPortile.new("openssl", openssl_version)

$recipes[:libssh2].files << "http://www.libssh2.org/download/libssh2-#{libssh2_version}.tar.gz"
$recipes[:openssl].files << "http://www.openssl.org/source/openssl-#{openssl_version}.tar.gz"

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

namespace :cross do
  # This cross compiles OpenSSL for Windows. This is ONLY called by `cross`
  # and should not be invoked manually.
  task :openssl do
    recipe = $recipes[:openssl]

    class << recipe
      def configure
        cmd = ["perl"]
        cmd << "Configure"
        cmd << "mingw"
        cmd << "no-zlib"
        cmd << "no-shared"
        cmd << "--cross-compile-prefix=i686-w64-mingw32-"
        cmd << configure_prefix

        execute("configure", cmd.join(" "))
      end

      def configured?
        false
      end
    end

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
  Rake::Task["compile"].prerequisites.unshift("cross:openssl", "ports:libssh2")
end
