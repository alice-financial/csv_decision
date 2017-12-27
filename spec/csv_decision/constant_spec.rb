# frozen_string_literal: true

require_relative '../../lib/csv_decision'

describe CSVDecision::Constant do
  context 'cell string value recognition' do
    cells = {
      ':= 0.0' => { operator: ':=', value: '0.0' },
      ':= 0.'  => { operator: ':=', value: '0.' },
      ':= .0'  => { operator: ':=', value:  '.0' },
      '==0.0'  => { operator: '==', value: '0.0' },
      '== 0.'  => { operator: '==', value: '0.' },
      '==.0'   => { operator: '==', value:  '.0' },
      '=0.0'   => { operator: '=',  value: '0.0' },
      '= 0.'   => { operator: '=',  value: '0.' },
      '=.0'    => { operator: '=',  value:  '.0' },
      '= nil'  => { operator: '=',  value: 'nil' },
      ':= nil' => { operator: ':=', value: 'nil' },
      '==nil'  => { operator: '==', value:  'nil' }
    }
    cells.each_pair do |cell, expected|
      it "recognises #{cell} as a constant" do
        match = described_class::EXPRESSION.match(cell)
        expect(match['operator']).to eq expected[:operator]
        expect(match['value']).to eq expected[:value]
      end
    end
  end

  describe '#matches?' do
    context 'constant matches value' do
      data = [
          ['= 1',    1],
          ['== 1',   1],
          [':=1',    1],
          ['==.1',   BigDecimal('0.1')],
          [':= 1.1', BigDecimal('1.1')]
      ]

      data.each do |cell, value|
        it "constant #{cell} matches #{value}" do
          proc = described_class.matches?(cell)
          expect(proc).to be_a(CSVDecision::Proc)
          expect(proc.type).to eq :constant
          expect(proc.function).to eq value
        end
      end
    end

    context 'does not match strings and non-constants' do
      data = ['true', 'nil', 'false', ':column', '> 0', '!= 1.0', 'abc.*def', '-1..1', '0...3']

      data.each do |cell|
        it "cell #{cell} is not a non-string constant}" do
          expect(described_class.matches?(cell)).to eq false
        end
      end
    end
  end
end