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
