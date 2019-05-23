lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "orgupdatematrix/version"

Gem::Specification.new do |spec|
  spec.name          = "orgupdatematrix"
  spec.version       = OrgUpdateMatrix::VERSION
  spec.authors       = ["Mark Luntzel"]
  spec.email         = ["mark@luntzel.com"]

  spec.summary       = %q{"Updates a YAML file with Capistrano deploy data"}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/ProjectVegas/orgupdatematrix"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/ProjectVegas/orgupdatematrix"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4"
  spec.add_dependency "octokit", "~> 4"
  spec.add_dependency "octopoller"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
