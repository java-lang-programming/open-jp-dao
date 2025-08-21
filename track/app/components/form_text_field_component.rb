# frozen_string_literal: true

class FormTextFieldComponent < ViewComponent::Base
  def initialize(form:, attribute:, form_status:, placeholder_key:, required: false)
    @form = form
    @attribute = attribute
    @form_status = form_status
    @placeholder_key = placeholder_key
    @required = required
  end

  def required?
    @required
  end

  def placeholder_text
    # プレースホルダーのキーを使ってI18nからテキストを取得
    t(@placeholder_key)
  end

  def border_color_class
    status = @form_status[@attribute][:status]
    case status
    when "complete"
      "border-green-500"
    when "failure"
      "border-red-500"
    else
      "border-gray-200"
    end
  end

  def error_hidden_class
    @form_status[@attribute][:status] == "failure" ? "" : "hidden"
  end

  def ok_hidden_class
    @form_status[@attribute][:status] == "complete" ? "" : "hidden"
  end
end
