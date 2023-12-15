require_relative "lib/ruby_auth_metamask/version"

Gem::Specification.new do |spec|
  spec.name        = "ruby_auth_metamask"
  spec.version     = RubyAuthMetamask::VERSION
  spec.authors     = ["Ethan Zhang"]
  spec.email       = ["yzhang.wa@gmail.com"]
  spec.homepage    = "https://github.com/yzhanginwa/ruby_auth_metamask"
  spec.summary     = "A Ruby on Rails Engine to authenticate metamask users"
  spec.description = "This is a Ruby on Rails Engine. It authenticates users against their metamask signature."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yzhanginwa/ruby_auth_metamask"
  spec.metadata["changelog_uri"] = "https://github.com/yzhanginwa/ruby_auth_metamask"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.2"
  spec.add_dependency "ecdsa"
  spec.add_dependency "keccak"
end
