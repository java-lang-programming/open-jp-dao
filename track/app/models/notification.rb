class Notification < ApplicationRecord
  def self.header(start_at: Time.now, end_at: Time.now)
    Notification.where(start_at: ..start_at).where(end_at: end_at..).order(priority: "DESC").order(created_at: "DESC")
  end
end
