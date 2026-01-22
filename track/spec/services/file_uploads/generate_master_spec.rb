require 'rails_helper'

RSpec.describe FileUploads::GenerateMaster, type: :feature do
  describe 'master' do
    context 'LEDGER_YAMLの場合' do
      # ヘッダーの属性が多い
      it "should be errors when failure" do
        instance = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::LEDGER_YAML)
        expect(instance.master).to eq(
          { "fields" => [ "date", "ledger_item", "name", "face_value", "proportion_rate", "proportion_amount" ], "date" => { "type" => "date", "options" => { "format" => "yyyy/mm/dd" }, "require" => true }, "ledger_item" => { "type" => "string", "options" => { "max" => 100 }, "require" => true, "relations" => { "has_many" => "ledgers.item" } }, "name" => { "type" => "string", "options" => { "max" => 100 }, "require" => false }, "face_value" => { "type" => "money_en", "require" => true }, "proportion_rate" => { "type" => "bigdecimal", "require" => false }, "proportion_amount" => { "type" => "bigdecimal", "require" => false } }
        )
      end
    end

    context 'when UFJ_YAML' do
      it "should get master data." do
        instance = FileUploads::GenerateMaster.new(kind: FileUploads::GenerateMaster::UFJ_YAML)
        expect(instance.master).to eq(
          { "fields" => [ "日付", "摘要", "摘要内容", "支払い金額", "預かり金額", "差引残高" ],
            "日付" => {
              "type" => "date",
              "options" => { "format" => "yyyy/mm/dd" },
              "require" => true
            },
            "摘要" => {
              "type" => "string",
              "options" => { "max" => 100 },
              "require" => true
            },
            "摘要内容" => {
              "type" => "string",
              "options" => { "max" => 100 },
              "require" => true
            },
            "支払い金額" => {
              "type" => "money_en",
              "require" => false
            },
            "預かり金額" => {
              "type" => "money_en",
              "require" => false
            },
            "差引残高" => {
              "type" => "money_en",
              "require" => true
            }
          }
        )
      end
    end
  end
end
