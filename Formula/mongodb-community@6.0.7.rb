class MongodbCommunityAT607 < Formula
  desc "High-performance, schema-free, document-oriented database"
  homepage "https://www.mongodb.com/"

  # frozen_string_literal: true

  if Hardware::CPU.intel?
    url "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-6.0.7.tgz"
    sha256 "3ec3fff19e442bc3a64c138f8554baf998ef8855589d388599849c545b669c61"
  else
    url "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-6.0.7.tgz"
    sha256 "00a2bd194a340c56bd9c81d1ec7b73c065bc98eb3339ff2ca2fbc803f71c62d7"
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
