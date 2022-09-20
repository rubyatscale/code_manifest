# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'set'
require 'tmpdir'

RSpec.describe CodeManifest::Rule do
  let(:root) { Pathname.new('tmp/rule_spec').expand_path }
  let(:pattern) { '**/*' }
  let(:rule) { described_class.new(root, pattern) }

  describe '#exclude' do
    context 'when exclude pattern' do
      let(:pattern) { '!foo' }

      it 'returns true' do
        expect(rule.exclude).to eq(true)
      end
    end

    context 'when not exclude pattern' do
      it 'returns false' do
        expect(rule.exclude).to eq(false)
      end
    end
  end

  describe '#glob' do
    context 'when pattern is rooted' do
      let(:pattern) { '/foo' }

      it 'returns rooted glob' do
        expect(rule.glob).to eq(root.join('foo').to_s)
      end
    end

    context 'when pattern is not rooted' do
      let(:pattern) { 'foo' }

      it 'returns non-rooted glob' do
        expect(rule.glob).to eq(root.join('**/foo').to_s)
      end
    end
  end

  describe '#files' do
    let(:root) { Pathname.new('.').expand_path }
    let(:pattern) { '**/*' }
    let(:rule) { described_class.new(root, pattern) }

    around do |example|
      Dir.mktmpdir do |tmp_dir|
        Dir.chdir(tmp_dir) do
          FileUtils.mkdir(root.join('bar'))
          FileUtils.touch(root.join('foo'))
          example.run
        end
      end
    end

    it 'excludes directories' do
      dir = root.join('dir')
      dir.mkpath

      expect(rule.files).not_to include(dir.to_s)
    end

    it 'returns a Set' do
      expect(rule.files).to be_a(Set)
    end

    context 'when pattern is for specific files' do
      let(:pattern) { 'foo' }

      it 'returns matched files' do
        FileUtils.touch(root.join('bar'))

        expect(rule.files).to eq(Set.new(['foo']))
      end
    end

    context 'when dotfiles are involved' do
      let(:pattern) { '**/*' }

      it 'supports dotfiles' do
        FileUtils.touch(root.join('.bar'))

        expected = Set.new([
          '.bar',
          'foo',
        ])

        expect(rule.files).to eq(expected)
      end
    end

    context 'when using union patterns' do
      let(:pattern) { 'foo.{x,y}' }

      it 'supports dotfiles' do
        FileUtils.touch(root.join('foo.x'))
        FileUtils.touch(root.join('foo.y'))
        FileUtils.touch(root.join('foo.z'))

        expected = Set.new([
          'foo.x',
          'foo.y',
        ])

        expect(rule.files).to eq(expected)
      end
    end
  end

  describe '#match?' do
    context 'when matched' do
      it 'returns true' do
        expect(rule.match?('foo')).to eq(true)
        expect(rule.match?('.foo')).to eq(true)
        expect(rule.match?('nested/foo/bar')).to eq(true)
      end
    end

    context 'when not matched' do
      let(:pattern) { '/bar' }

      it 'returns false' do
        expect(rule.match?('foo')).to eq(false)
      end
    end
  end
end
