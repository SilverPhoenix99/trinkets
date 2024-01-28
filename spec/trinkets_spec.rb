# frozen_string_literal: true

require_relative '../lib/trinkets/version'

RSpec.describe Trinkets do
  it "has a version number" do
    expect(Trinkets::VERSION).not_to be nil
  end
end
