# frozen_string_literal: true

require 'pathname'
require 'fileutils'

RSpec.describe CodeManifest::Manifest do
  let(:root) { Pathname.new('tmp/manifest_spec').expand_path }

  describe '#files' do
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
      expect(manifest.files).to match_array(['bar/include', 'foo'])
    end

    context 'with different type of globs' do
      let(:patterns) { ['dir_bar/**/*'] }
      let(:manifest) { described_class.new(root.expand_path, patterns) }

      around do |example|
        Dir.mktmpdir do |tmp_dir|
          Dir.chdir(tmp_dir) do
            FileUtils.mkdir(root.join('dir_bar'))
            FileUtils.touch(root.join('dir_bar/foo'))
            example.run
          end
        end
      end

      it 'excludes directories' do
        dir = root.join('dir_bar/dir')
        dir.mkpath

        expect(manifest.files).not_to include(dir.to_s)
      end

      context 'when pattern is for specific files' do
        let(:patterns) { ['dir_bar/foo'] }

        it 'returns matched files' do
          FileUtils.touch(root.join('dir_bar/bar'))

          expect(manifest.files).to match_array(['dir_bar/foo'])
        end
      end

      context 'when dotfiles are involved' do
        let(:patterns) { ['dir_bar/**/*'] }

        it 'supports dotfiles' do
          FileUtils.touch(root.join('dir_bar/.bar'))

          expected = [
            'dir_bar/.bar',
            'dir_bar/foo',
          ]

          expect(manifest.files).to match_array(expected)
        end
      end

      context 'when using union patterns' do
        let(:patterns) { ['foo.{x,y}'] }

        it 'supports dotfiles' do
          FileUtils.touch(root.join('foo.x'))
          FileUtils.touch(root.join('foo.y'))
          FileUtils.touch(root.join('foo.z'))

          expected = [
            'foo.x',
            'foo.y',
          ]

          expect(manifest.files).to match_array(expected)
        end
      end
    end
  end

  describe '#digest' do
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

  describe '#matches' do
    let(:patterns) { ['/foo', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(root.expand_path, patterns) }
    let(:paths) do
      [
        'bar/exclude',
        'bar/iniclude',
        'foo',
        'baz/baz.md'
      ]
    end

    around do |example|
      root.mkpath
      root.join('bar').mkpath
      root.join('baz').mkpath

      paths.each do |path|
        FileUtils.touch(root.join(path))
      end

      example.run
      root.rmtree
    end

    it 'returns matched paths' do
      expect(manifest.matches(paths)).to match_array([
        'bar/iniclude',
        'foo',
      ])
    end
  end
end
