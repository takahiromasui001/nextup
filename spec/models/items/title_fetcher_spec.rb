require 'rails_helper'

RSpec.describe Items::TitleFetcher do
  subject { described_class.new(url).fetch }

  context '正常系' do
    let(:url) { 'https://example.com' }
    let(:html) { '<html><head><title>Example Domain</title></head></html>' }

    before do
      allow(URI).to receive(:open).and_yield(StringIO.new(html))
      allow(Resolv).to receive(:getaddress).with('example.com').and_return('93.184.216.34')
    end

    it 'タイトルを返す' do
      expect(subject).to eq('Example Domain')
    end

    context 'HTMLエンティティを含むタイトル' do
      let(:html) { '<html><head><title>Foo &amp; Bar</title></head></html>' }

      it 'アンエスケープされたタイトルを返す' do
        expect(subject).to eq('Foo & Bar')
      end
    end
  end

  context 'SSRF対策' do
    before do
      allow(URI).to receive(:open).and_raise(RuntimeError, 'should not be called')
    end

    context '127.x のアドレス' do
      let(:url) { 'http://127.0.0.1' }

      before { allow(Resolv).to receive(:getaddress).and_return('127.0.0.1') }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end

    context '10.x のアドレス' do
      let(:url) { 'http://10.0.0.1' }

      before { allow(Resolv).to receive(:getaddress).and_return('10.0.0.1') }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end

    context '172.16.x のアドレス' do
      let(:url) { 'http://172.16.0.1' }

      before { allow(Resolv).to receive(:getaddress).and_return('172.16.0.1') }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end

    context '192.168.x のアドレス' do
      let(:url) { 'http://192.168.1.1' }

      before { allow(Resolv).to receive(:getaddress).and_return('192.168.1.1') }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end

    context '::1 のアドレス' do
      let(:url) { 'http://[::1]' }

      before { allow(Resolv).to receive(:getaddress).and_return('::1') }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end
  end

  context '許可されていないスキーム' do
    context 'ftp://' do
      let(:url) { 'ftp://example.com/file' }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end

    context 'javascript:' do
      let(:url) { 'javascript:alert(1)' }

      it 'nilを返す' do
        expect(subject).to be_nil
      end
    end
  end

  context '無効なURL' do
    let(:url) { 'not a url' }

    it 'nilを返す' do
      expect(subject).to be_nil
    end
  end

  context 'blank' do
    let(:url) { '' }

    it 'nilを返す' do
      expect(subject).to be_nil
    end
  end

  context 'タイムアウト' do
    let(:url) { 'https://example.com' }

    before do
      allow(Resolv).to receive(:getaddress).with('example.com').and_return('93.184.216.34')
      allow(URI).to receive(:open).and_raise(Net::OpenTimeout)
    end

    it 'nilを返す' do
      expect(subject).to be_nil
    end
  end

  context 'DNS解決失敗' do
    let(:url) { 'https://nonexistent.invalid' }

    before do
      allow(Resolv).to receive(:getaddress).and_raise(Resolv::ResolvError)
    end

    it 'nilを返す' do
      expect(subject).to be_nil
    end
  end
end
