class MongodbCommunityAT60 < Formula
  desc "High-performance, schema-free, document-oriented database"
  homepage "https://www.mongodb.com/"

  # frozen_string_literal: true

  if Hardware::CPU.intel?
    url "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-6.0.12.tgz"
    sha256 "6c420c804a07bac3131eaaf95de17d603358e63917b4cd610a57cf8fcfb9ae89"
  else
    url "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-6.0.12.tgz"
    sha256 "0c45c9a858cb6237aed4db932e1e2aaf57259cd6c39b2a45c844a12e16141de6"
  end

  option "with-enable-test-commands", "Configures MongoDB to allow test commands such as failpoints"

  depends_on "mongodb/brew/mongodb-database-tools" => :recommended
  depends_on "mongodb/brew/mongosh" => :recommended

  conflicts_with "mongodb/brew/mongodb-enterprise"

  def install
    inreplace "macos_mongodb.plist" do |s|
      s.gsub!("\#{plist_name}", "#{plist_name}")
      s.gsub!("\#{opt_bin}", "#{opt_bin}")
      s.gsub!("\#{etc}", "#{etc}")
      s.gsub!("\#{HOMEBREW_PREFIX}", "#{HOMEBREW_PREFIX}")
      s.gsub!("\#{var}", "#{var}")
    end

    prefix.install Dir["*"]
    prefix.install_symlink "macos_mongodb.plist" => "#{plist_name}.plist"
  end

  def post_install
    (var/"mongodb").mkpath
    (var/"log/mongodb").mkpath
    if !(File.exist?((etc/"mongod.conf"))) then
      (etc/"mongod.conf").write mongodb_conf
    end
  end

  def mongodb_conf
    cfg = <<~EOS
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1, ::1
      ipv6: true
    EOS
    if build.with? "enable-test-commands"
      cfg += <<~EOS
      setParameter:
        enableTestCommands: 1
      EOS
    end
    cfg
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
