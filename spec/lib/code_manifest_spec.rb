# frozen_string_literal: true

RSpec.describe CodeManifest do
  before { stub_const("#{described_class}::DOTFILE", '.code_manifest_test.yml') }

  describe '.[]' do
    it 'reads manifest out' do
      expect(described_class['foo']).to be_a(CodeManifest::Manifest)
      expect(described_class['foo'].files).to include('spec/fixtures/foo/bar.txt', 'spec/fixtures/foo/foo.md')
      expect(described_class['foo'].digest).to eq('30c55dba4f38d996651d236f4263cf6a')
    end

    context 'when manifest does not exist' do
      it 'returns nil' do
        expect(described_class['fooo']).to be_nil
      end
    end
  end
end
