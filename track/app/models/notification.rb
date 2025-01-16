class Notification < ApplicationRecord
  scope :header, -> { where(start_at: ..Time.now).where(end_at: Time.now..).order(priority: "DESC").order(created_at: "DESC") }
  # Notification.where(start_at: ..Time.now).where(end_at: Time.now..).order(priority: "DESC").order(created_at: "DESC").first
end
