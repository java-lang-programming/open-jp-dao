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
  end
end
