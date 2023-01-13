# frozen_string_literal: true

require_relative 'lib/shi/jekyll/images/version'

Gem::Specification.new do |spec|
  spec.name = 'shi-jekyll-images'
  spec.version = Shi::Jekyll::Images::VERSION
  spec.authors = ['Ivan Shikhalev']
  spec.email = ['shikhalev@gmail.com']

  spec.summary = 'Jekyll plugin for image manipulation'
  spec.homepage = 'https://github.com/shikhalev/shi-jekyll-images'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.7'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/shikhalev/shi-jekyll-images'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency 'jekyll', '>= 4.0', '< 5.0'
  spec.add_dependency 'liquid', '~> 4.0'
  spec.add_dependency 'shi-tools', '~> 0.2.0'
  spec.add_dependency 'shi-args', '~> 0.3.4.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
