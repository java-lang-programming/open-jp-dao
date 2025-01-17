require 'rails_helper'

RSpec.describe "Apis::Notifications", type: :request do
  describe "GET /index" do
    context 'success' do
    it "returns http success" do
      get apis_notifications_index_path
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json).to eq({ notification: {} })
    end
    end

    context 'failure' do
      let(:notification_start_at_now) { create(:notification_start_at_now) }

      it "returns http success" do
        notification_start_at_now
        get apis_notifications_index_path
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:notification][:id]).to eq(notification_start_at_now.id)
        expect(json[:notification][:message]).to eq(notification_start_at_now.message)
      end
    end
  end
end
