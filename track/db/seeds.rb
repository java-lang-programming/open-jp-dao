current_env = Rails.env.downcase
if current_env == development
  load(Rails.root.join("db", "seeds", "#{Rails.env.downcase}.rb"))
  load(Rails.root.join("db", "seeds", "#{Rails.env.downcase}_v2.rb"))
else
  load(Rails.root.join("db", "seeds", "#{Rails.env.downcase}.rb"))
end
