# frozen_string_literal: true

require_relative '../../../lib/csv_decision'

describe CSVDecision::Matchers::Numeric do
  subject { described_class.new }

  describe '#new' do
    it { is_expected.to be_a CSVDecision::Matchers::Numeric }
    it { is_expected.to respond_to(:matches?).with(1).argument }
  end

  context 'cell value recognition' do
    cells = {
      '> -1' => { comparator: '>', value: '-1' },
      '>= 10.0' => { comparator: '>=', value: '10.0' },
      '< .0' => { comparator: '<', value: '.0' },
      '<= +1' => { comparator: '<=', value: '+1' }
    }
    cells.each_pair do |cell, expected|
      it "recognises #{cell} as a comparision" do
        match = described_class::COMPARISON.match(cell)
        expect(match['comparator']).to eq expected[:comparator]
        expect(match['value']).to eq expected[:value]
      end
    end
  end

  describe '#matches?' do
    matcher = described_class.new

    context 'comparison matches value' do
      data = [
          ['< 1',  0],
          ['< 1', '0'],
          ['> 1',  5],
          ['!= 1',  0],
          ['> 1', '5'],
          ['>= 1.1', BigDecimal('1.1')],
          ['<=-1.1', BigDecimal('-12')]
      ]

      data.each do |cell, value|
        it "comparision #{cell} matches #{value}" do
          proc = matcher.matches?(cell)
          expect(proc).to be_a(CSVDecision::Proc)
          expect(proc.type).to eq :proc
          expect(proc.function[value]).to eq true
        end
      end
    end

    context 'does not match non-numeric comparision' do
      data = ['1', ':column', ':= nil', ':= true', ':= 0', 'abc', 'abc.*def', '-1..1', '0...3']

      data.each do |cell|
        it "cell #{cell} is not a comparision}" do
          expect(matcher.matches?(cell)).to eq false
        end
      end
    end
  end
end