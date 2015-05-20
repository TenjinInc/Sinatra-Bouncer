require_relative 'spec_helper'

describe Sinatra::Bouncer::BasicBouncer do
  describe '#allow' do
    it 'should accept a single path'
    it 'should accept a list of paths'
    it 'should ignore start or end slashes'
    it 'should ignore case sensitivity when matching a path'
  end

  describe '#bounce' do
    # it 'should bounce by 401 if no bounces_by provided'
    it 'should bounce by a given block if bounces_by provided'
  end

  it 'should raise an exception when a rule block returns anything but explicit true or false'
  it 'should require that allow be given a block'
  it 'should apply the rule to all routes when :all is supplied as the path'
  #todo: in the error, mention that if they want to always allow, use always_allow instead
end