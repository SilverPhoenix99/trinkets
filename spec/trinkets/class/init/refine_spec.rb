# frozen_string_literal: true

require_relative '../../../../lib/trinkets/class/init/refine'

using ::Trinkets::Class::Init

RSpec.describe ::Trinkets::Class::Init do
  describe 'refine' do
    subject { Class.new }

    it 'defines self.init' do
      expect(subject.respond_to?(:init)).to be(true)
    end
  end
end
