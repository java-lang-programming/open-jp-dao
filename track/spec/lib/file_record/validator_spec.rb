require 'rails_helper'

RSpec.describe FileRecord::Validator, type: :lib do
  # ダミークラス
  let(:dummy_class) do
    Class.new do
      include FileRecord::Validator
    end
  end

  let(:instance) { dummy_class.new }
  let(:master) { FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::LEDGER_YAML).master }

  describe "#validate_money_en" do
    let(:field) { 'face_value' }
    let(:content) { master[field] }
    it "should be require error." do
      col = 4
      row_num = 1
      value = ''
      errors = instance.validate_money_en(
        content: content,
        col: col,
        row_num: row_num,
        field: field,
        value: value
      )
      expect(errors).to eq([ {
                              row: row_num,
                              col: col,
                              attribute: field,
                              value: value,
                              message: "face_valueが未記入です。face_valueは必須入力です。"
                            } ])
    end

    it "should be error." do
      col = 4
      row_num = 1
      value = 'aaaa'
      errors = instance.validate_money_en(
        content: content,
        col: col,
        row_num: row_num,
        field: field,
        value: value
      )
      expect(errors).to eq([ {
                             row: row_num,
                             col: col,
                             attribute: field,
                             value: value,
                             message: "face_valueは数値、もしくはカンマ区切りの数値です。"
                           } ])
    end
  end
end
