require 'rails_helper'


RSpec.describe Notification, type: :model do
  describe 'header' do
    let(:notification_start_at_now) { create(:notification_start_at_now) }
    let(:notification_start_at_tomorrow) { create(:notification_start_at_tomorrow) }

    context 'data found' do
      it 'should be header Notification.' do
        notification_start_at_now
        expect(Notification.header.first).to eq(notification_start_at_now)
      end
    end

    context 'data not found' do
      it 'should be not found header Notification.' do
        notification_start_at_tomorrow
        expect(Notification.header.first).to be nil
      end
    end
  end

  # describe 'header' do
  #   let(:notification_start_at_now) { create(:notification_start_at_now) }
  #   let(:notification_start_at_tomorrow) { create(:notification_start_at_tomorrow) }

  #   context 'data found' do
  #     it 'should be header Notification.' do
  #       notification_start_at_now
  #       expect(Notification.header.first).to eq(notification_start_at_now)
  #     end
  #   end

  #   context 'data not found' do
  #     it 'should be not found header Notification.' do
  #       notification_start_at_tomorrow
  #       expect(Notification.header.first).to be nil
  #     end
  #   end
  # end
end
