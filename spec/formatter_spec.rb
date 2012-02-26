# coding: UTF-8
require 'spec_helper'

# This code is changing too rapidly, in an untestable way
describe Sherpa::Formatter do
  let(:formatter) {Sherpa::Formatter}

  it "should work" do
    citations = [{citations: [{volume: 'I'}], them: {volume: 'II'}}]
    formatter.format_comparisons citations
  end

end
