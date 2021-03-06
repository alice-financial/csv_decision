# frozen_string_literal: true

require_relative '../../../lib/csv_decision'

describe CSVDecision::Matchers::Function do
  subject { described_class.new }

  describe '#new' do
    it { is_expected.to be_a CSVDecision::Matchers::Function }
    it { is_expected.to be_a CSVDecision::Matchers::Matcher }
    it { is_expected.to respond_to(:matches?).with(1).argument }
  end

  context 'cell value recognition' do
    cells = {
      ':=function' => { operator: ':=', name: 'function' },
      ':=function()' => { operator: ':=', name: 'function', args:'()' },
      ':=function(arg: value)' => { operator: ':=', name: 'function', args:'(arg: value)' },
      ':= !function(arg: value)' => { operator: ':=', negate: '!', name: 'function', args:'(arg: value)' },
      '== ! func(arg: val)' => { operator: '==', negate: '!', name: 'func', args:'(arg: val)' },
    }
    cells.each_pair do |cell, expected|
      it "recognises #{cell} as a function" do
        match = CSVDecision::Matchers::Function::FUNCTION_RE.match(cell)
        expect(match['operator']).to eq expected[:operator]
        expect(match['name']).to eq expected[:name]
      end
    end
  end

  describe '#matches?' do
    matcher = described_class.new

    # context 'symbol expression matches value to hash data' do
    #   examples = [
    #     { cell:  ':col',   value:  0,  hash: { col:  0 },  result: true },
    #     { cell:  ':col',   value: '0', hash: { col: '0' }, result: true },
    #     { cell:  ':col',   value:  0,  hash: { col: '0' }, result: false },
    #     { cell:  ':col',   value: '0', hash: { col:  0 },  result: false },
    #     { cell:  ':col',   value:  1,  hash: { col:  0 },  result: false },
    #     { cell:  ':key',   value:  0,  hash: { col:  0 },  result: false },
    #     { cell: '!=:col',  value:  0,  hash: { col:  0 },  result: false },
    #     { cell: '!=:col',  value: '0', hash: { col: '0' }, result: false },
    #     { cell: '!=:col',  value:  0,  hash: { col: '0' }, result: true },
    #     { cell: '!=:col',  value: '0', hash: { col:  0 },  result: true },
    #     { cell: '!=:col',  value:  1,  hash: { col:  0 },  result: true },
    #     { cell: '!=:key',  value:  0,  hash: { col:  0 },  result: true },
    #     { cell:  '>:col',  value:  1,  hash: { col:  0 },  result: true },
    #     { cell:  '>:col',  value:  0,  hash: { col:  1 },  result: false },
    #     { cell:  '<:col',  value:  0,  hash: { col:  1 },  result: true },
    #     { cell:  '<:col',  value:  1,  hash: { col:  0 },  result: false },
    #     { cell:  '= :col', value:  0,  hash: { col:  0 },  result: true },
    #     { cell:  '==:col', value:  0,  hash: { col:  0 },  result: true },
    #     { cell:  ':=:col', value:  0,  hash: { col:  0 },  result: true },
    #     { cell:  '= :col', value: '0', hash: { col:  0 },  result: false },
    #     { cell:  '>=:col', value:  1,  hash: { col:  0 },  result: true },
    #     { cell:  '>=:col', value:  0,  hash: { col:  1 },  result: false },
    #     { cell:  '<=:col', value:  0,  hash: { col:  1 },  result: true },
    #     { cell:  '<=:col', value:  1,  hash: { col:  0 },  result: false },
    #     { cell:  '<=:col', value: '1', hash: { col:  1 },  result: false },
    #   ]
    #
    #   examples.each do |ex|
    #     it "cell #{ex[:cell]} matches value: #{ex[:value]} to hash: #{ex[:hash]}" do
    #       proc = matcher.matches?(ex[:cell])
    #       expect(proc).to be_a(CSVDecision::Proc)
    #       expect(proc.function.call(ex[:value], ex[:hash])).to eq ex[:result]
    #     end
    #   end
    # end

    context 'does not match a non-function string' do
      data = ['1', 'abc', 'abc.*def', '-1..1', '0...3']

      data.each do |cell|
        it "cell #{cell} is not a function" do
          expect(matcher.matches?(cell)).to eq false
        end
      end
    end
  end
end