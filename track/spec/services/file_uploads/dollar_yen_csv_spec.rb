require 'rails_helper'

RSpec.describe FileUploads::DollarYenCsv, type: :feature do
  describe 'validation_errors' do
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    context 'success' do
      it 'should get no validation_errors.' do
        service = FileUploads::DollarYenCsv.new(file: success_csv_path)
        expect(service.validation_errors).to eq([])
      end
    end
  end

  describe 'make_dollar_yens' do
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    context 'success' do
      it 'should get 5 dollar_yens.' do
        service = FileUploads::DollarYenCsv.new(file: success_csv_path)
        service.validation_errors

        dollar_yens = service.make_dollar_yens
        expect(dollar_yens.length).to eq(5)
      end
    end
  end

  describe 'execute' do
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    context 'success' do
      it 'should insert 5 dollar_yens.' do
        service = FileUploads::DollarYenCsv.new(file: success_csv_path)
        service.execute

        expect(DollarYen.all.length).to eq(5)
      end
    end
  end

  describe 'async_execute' do
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    context 'success' do
      it 'should insert 5 dollar_yens.' do
        service = FileUploads::DollarYenCsv.new(file: success_csv_path)
        service.async_execute

        expect(DollarYen.all.length).to eq(5)
      end
    end
  end
end
