# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormTextFieldComponent, type: :component do
  let(:form) { instance_double("FormBuilder") }
  let(:attribute) { :deposit_quantity }
  let(:placeholder_key) { "activerecord.attributes.dollar_yen_transaction.deposit_quantity" }

  describe "#border_color_class" do
    context "フォームのステータスが 'complete' の場合" do
      let(:form_status) { { deposit_quantity: { status: 'complete' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "緑色の枠線クラスを返すこと" do
        expect(component.border_color_class).to eq("border-green-500")
      end
    end

    context "フォームのステータスが 'failure' の場合" do
      let(:form_status) { { deposit_quantity: { status: 'failure' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "赤色の枠線クラスを返すこと" do
        expect(component.border_color_class).to eq("border-red-500")
      end
    end

    context "フォームのステータスがその他の場合（例：'pending' や設定なし）" do
      let(:form_status) { { deposit_quantity: { status: 'pending' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "デフォルトの灰色の枠線クラスを返すこと" do
        expect(component.border_color_class).to eq("border-gray-200")
      end
    end
  end

  describe "#error_hidden_class" do
    context "フォームのステータスが 'failure' の場合" do
      let(:form_status) { { deposit_quantity: { status: 'failure' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "エラーメッセージを表示するために空文字列を返すこと" do
        expect(component.error_hidden_class).to eq("")
      end
    end

    context "フォームのステータスが 'failure' ではない場合" do
      let(:form_status) { { deposit_quantity: { status: 'complete' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "エラーメッセージを非表示にするために 'hidden' を返すこと" do
        expect(component.error_hidden_class).to eq("hidden")
      end
    end
  end

  describe "#ok_hidden_class" do
    context "フォームのステータスが 'complete' の場合" do
      let(:form_status) { { deposit_quantity: { status: 'complete' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "成功アイコンを表示するために空文字列を返すこと" do
        expect(component.ok_hidden_class).to eq("")
      end
    end

    context "フォームのステータスが 'complete' ではない場合" do
      let(:form_status) { { deposit_quantity: { status: 'failure' } } }
      let(:component) { described_class.new(form: form, attribute: attribute, form_status: form_status, placeholder_key: placeholder_key) }

      it "成功アイコンを非表示にするために 'hidden' を返すこと" do
        expect(component.ok_hidden_class).to eq("hidden")
      end
    end
  end
end
