# frozen_string_literal: true

require 'pathname'
require 'fileutils'

RSpec.describe CodeManifest::Manifest do
  describe '#files' do
    let(:root) { Pathname.new('tmp/manifest_spec').expand_path }
    let(:patterns) { ['/foo', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(root.expand_path, patterns) }

    around do |example|
      root.mkpath
      FileUtils.touch(root.join('foo'))
      root.join('bar').mkpath
      FileUtils.touch(root.join('bar/include'))
      FileUtils.touch(root.join('bar/exclude'))
      example.run
      root.rmtree
    end

    it 'returns only included files' do
      expect(manifest.files).to include('bar/include', 'foo')
    end
  end

  describe '#digest' do
    let(:root) { Pathname.new('tmp/manifest_spec').expand_path }
    let(:patterns) { ['/foo', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(root.expand_path, patterns) }

    around do |example|
      root.mkpath
      FileUtils.touch(root.join('foo'))
      root.join('bar').mkpath
      FileUtils.touch(root.join('bar/include'))
      FileUtils.touch(root.join('bar/exclude'))
      example.run
      root.rmtree
    end

    it 'returns only included files' do
      expect(manifest.digest).to eq('020eb29b524d7ba672d9d48bc72db455')
    end
  end
end
