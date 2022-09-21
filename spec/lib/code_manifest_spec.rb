# frozen_string_literal: true

require 'fileutils'

RSpec.describe CodeManifest do
  describe '.[]' do
    it 'reads manifest out' do
      expect(described_class['foo']).to be_a(CodeManifest::Manifest)
      expect(described_class['foo'].files).to include('foo/bar.txt', 'foo/foo.md')
      expect(described_class['foo'].digest).to eq('30c55dba4f38d996651d236f4263cf6a')
    end

    context 'when manifest does not exist' do
      it 'returns nil' do
        expect(described_class['fooo']).to be_nil
      end
    end
  end
end
