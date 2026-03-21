Rails.application.config.session_store :cookie_store,
                                       key: "_wanwan_#{Rails.env}_session",
                                       secure: Rails.env.production? || Rails.env.staging?,
                                       httponly: true,
                                       expire_after: 2.weeks,
                                       same_site: :lax # 明示的に指定
