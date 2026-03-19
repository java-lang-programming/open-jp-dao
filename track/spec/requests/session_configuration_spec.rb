require 'rails_helper'

RSpec.describe "セッション管理の設定", type: :request do
  let(:session_store) { Rails.application.config.session_store }
  let(:session_options) { Rails.application.config.session_options }

  it "CookieStoreを使用していること" do
    expect(session_store).to eq ActionDispatch::Session::CookieStore
  end

  it "環境に応じた適切なKey名が設定されていること" do
    expect(session_options[:key]).to eq "_wanwan_#{Rails.env}_session"
  end

  it "有効期限が2週間に設定されていること" do
    expect(session_options[:expire_after]).to eq 2.weeks
  end

  it "セキュリティ設定（HttpOnly, SameSite）が正しいこと" do
    expect(session_options[:httponly]).to be true
    expect(session_options[:same_site]).to eq :lax
  end

  if Rails.env.production? || Rails.env.staging?
    it "本番系環境でSecure属性が有効であること" do
      expect(session_options[:secure]).to be true
    end
  end
end
