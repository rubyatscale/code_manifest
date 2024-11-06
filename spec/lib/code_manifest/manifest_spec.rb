# frozen_string_literal: true

require 'pathname'
require 'fileutils'

RSpec.describe CodeManifest::Manifest do
  let(:root) { CodeManifest.root }

  describe '#files' do
    let(:patterns) { ['/foo/foo.md', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(patterns) }

    around do |example|
      root.join('bar').mkpath
      FileUtils.touch(root.join('bar/include'))
      FileUtils.touch(root.join('bar/exclude'))
      example.run
    end

    it 'returns only included files' do
      expect(manifest.files).to match_array(['bar/include', 'foo/foo.md'])
    end

    context 'when there are duplicate patterns' do
      let(:patterns) { ['/foo/foo.md', 'bar/*', '!bar/exclude', 'bar/*'] }

      it 'dedups files' do
        expect(manifest.files).to match_array(['bar/include', 'foo/foo.md'])
      end
    end

    context 'with different type of globs' do
      let(:patterns) { ['dir_bar/**/*'] }
      let(:manifest) { described_class.new(patterns) }

      around do |example|
        FileUtils.mkdir(root.join('dir_bar'))
        FileUtils.touch(root.join('dir_bar/foo'))
        example.run
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
            'dir_bar/foo'
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
            'foo.y'
          ]

          expect(manifest.files).to match_array(expected)
        end
      end
    end
  end

  describe '#digest' do
    let(:patterns) { ['/foo', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(patterns) }

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
      expect(manifest.digest).to eq('74be16979710d4c4e7c6647856088456')
    end
  end

  describe '#matches' do
    let(:patterns) { ['/foo', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(patterns) }
    let(:paths) do
      [
        'bar/exclude',
        'bar/include',
        'foo',
        'baz/baz.md'
      ]
    end

    it 'returns matched paths' do
      expect(manifest.matches(paths)).to match_array([
                                                       'bar/include',
                                                       'foo'
                                                     ])
    end

    context 'caching concerns' do
      let(:patterns) { ['/foo', '!bar/exclude'] }
      let(:paths) { ['foo'] }

      it 'caches rule lookups' do
        include_rule = manifest.rules[0]
        exclude_rule = manifest.rules[1]

        expect(include_rule).to receive(:match?).with('foo').once.and_return(true)
        expect(exclude_rule).to receive(:match?).with('foo').once.and_return(false)

        manifest.matches(paths)
        manifest.matches(paths)
      end
    end
  end

  describe '#matches_all?' do
    let(:patterns) { ['/foo', 'bar/*', '!bar/exclude'] }
    let(:manifest) { described_class.new(patterns) }
    let(:paths) do
      [
        'foo',
        'bar/include2',
        'bar/include1',
      ]
    end

    it 'returns true if all paths are matched' do
      expect(manifest.matches_all?(paths)).to be(true)
    end

    context 'when not all paths are matched' do
      let(:paths) do
        [
          'bar/include',
          'bar/exclude',
          'foo'
        ]
      end

      it 'returns false' do
        expect(manifest.matches_all?(paths)).to be(false)
      end
    end
  end
end
