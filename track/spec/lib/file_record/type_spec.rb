require 'rails_helper'

RSpec.describe FileRecord::Type, type: :lib do
  # ダミークラス
  let(:dummy_class) do
    Class.new do
      include FileRecord::Type
    end
  end

  let(:instance) { dummy_class.new }

  describe "#money_to_numeric" do
    subject { instance.money_to_numeric(value: value) }

    context 'ドル表記やその他通貨記号が含まれる場合' do
      context 'ドル記号とカンマ付きの小数（"$1,432.22"）の場合' do
        let(:value) { '$1,432.22' }

        it 'Float に変換されること' do
          expect(subject).to eq 1432.22
          expect(subject).to be_a(Float)
        end
      end

      context '円記号とカンマ付きの整数（"¥14,012"）の場合' do
        let(:value) { '¥14,012' }

        it 'Integer に変換されること' do
          expect(subject).to eq 14012
          expect(subject).to be_a(Integer)
        end
      end

      context 'ユーロ表記（"€1,432.22"）の場合' do
        let(:value) { '€1,432.22' }

        it 'Float に変換されること' do
          expect(subject).to eq 1432.22
          expect(subject).to be_a(Float)
        end
      end
    end

    context '整数値として評価される入力の場合' do
      context 'カンマ付きの整数文字列の場合' do
        let(:value) { '14,012' }

        it 'Integer に変換されること' do
          expect(subject).to eq 14012
          expect(subject).to be_a(Integer)
        end
      end

      context 'シングルクォート付きの整数文字列の場合' do
        let(:value) { "'14,012'" }

        it 'Integer に変換されること' do
          expect(subject).to eq 14012
          expect(subject).to be_a(Integer)
        end
      end
    end

    context '小数値として評価される入力の場合' do
      context 'カンマ付きの小数文字列（"1,432.22"）の場合' do
        let(:value) { '1,432.22' }

        it 'Float に変換されること' do
          expect(subject).to eq 1432.22
          expect(subject).to be_a(Float)
        end
      end

      context 'シングルクォート付きの小数文字列の場合' do
        let(:value) { "'1,432.22'" }

        it 'Float に変換されること' do
          expect(subject).to eq 1432.22
          expect(subject).to be_a(Float)
        end
      end

      context '数値の Float（1432.22）が渡された場合' do
        let(:value) { 1432.22 }

        it 'Float に変換されること' do
          expect(subject).to eq 1432.22
          expect(subject).to be_a(Float)
        end
      end
    end

    context '異常系: 数値に変換できない入力の場合' do
      context '数値以外の文字列の場合' do
        let(:value) { 'invalid' }

        it 'ArgumentError が発生すること' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'nil が渡された場合' do
        let(:value) { nil }

        it 'ArgumentError が発生すること' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
