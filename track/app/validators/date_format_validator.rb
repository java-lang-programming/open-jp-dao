class DateFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, "を入力してください")
      return
    end

    unless value.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      record.errors.add(attribute, "はYYYY-MM-DD形式で入力してください")
      return
    end

    begin
      Date.strptime(value.to_s, "%Y-%m-%d")
    rescue ArgumentError
      record.errors.add(attribute, "は存在する日付を入力してください")
    end
  end
end
