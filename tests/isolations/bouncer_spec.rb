require_relative 'spec_helper'

describe Sinatra::Bouncer::BasicBouncer do
  let(:bouncer) { Sinatra::Bouncer::BasicBouncer.new }

  describe '#allow' do
    it 'should not raise an error if provided a block' do
      expect do
        bouncer.allow('some_path') do
          true
        end
      end
    end

    it 'should raise an error if not provided a block' do
      expect do
        bouncer.allow('some_path')
      end.to raise_error(Sinatra::Bouncer::BouncerError, 'You must provide a block to #allow. If you wish to always allow, either return true or use #always_allow instead')
    end
  end
end