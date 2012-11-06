require 'spec_helper'

describe Binged::Client do
  describe '.new' do
    context 'with a defunct api_key' do
      it 'raises' do
        expect {
          Binged::Client.new(:api_key => 'binged')
        }.to raise_error(ArgumentError)
      end
    end
  end
end