require 'rails_helper'

RSpec.describe DollarYenCsvImportJob, type: :job do
  describe 'perform_later' do
    let(:success_csv_path) { "#{Rails.root}/spec/files/uploads/dollar_yen_csv/success.csv" }

    # it 'enqueue job' do
    #   DollarYenCsvImportJob.perform_later(file_path: success_csv_path)
    #   expect(DollarYenCsvImportJob).to have_been_enqueued # キューに入ったかを確認する
    # end

    # it 'impoer DollarYen' do
    #   DollarYenCsvImportJob.perform_now(file_path: success_csv_path)
    #   expect(DollarYen.all.length).to eq(5)
    # end
  end
end
