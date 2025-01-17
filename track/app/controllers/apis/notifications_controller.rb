class Apis::NotificationsController < ApplicationController
  def index
    notification = Notification.header.first
    notification = {} unless notification.present?
    render json: { notification: notification }, status: :ok
  end
end
