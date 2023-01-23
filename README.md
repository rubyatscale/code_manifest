# CodeManifest

Simple manifest to fetch file by globs and generate digest.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add code_manifest

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install code_manifest

## Usage

Put a `.code_manifest.yml` config file under your project root, for example:

```yml
ruby:
  - app/**/*.rb
js:
  - frontend/**/*.js
```

Then use it with:

```ruby
require 'code_manifest'

# Returns a `Set` with filepaths
CodeManifest['ruby'].files
CodeManifest['js'].files

# Returns a digest based on all files specified under same namespace
CodeManifest['ruby'].digest
CodeManifest['js'].digest
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubyatscale/code_manifest.
