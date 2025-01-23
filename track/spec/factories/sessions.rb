FactoryBot.define do
  factory :session_sepolia, class: Session do
    address {  }
    ip_address { "190.32.11.1" }
    user_agent { "chrome" }
    chain_id { Session::ETHEREUM_SEPOLIA }
    message { "aaasadsdasasdsa" }
    signature { "aw32323423423423423432" }
    domain { "localhost" }
  end

  factory :session_ethereum_mainnet, class: Session do
    address {  }
    ip_address { "190.32.11.1" }
    user_agent { "chrome" }
    chain_id { Session::ETHEREUM_MAINNET }
    message { "aaasadsdasasdsa" }
    signature { "aw32323423423423423432" }
    domain { "localhost" }
  end

  factory :session_polygon_mainnet, class: Session do
    address {  }
    ip_address { "190.32.11.1" }
    user_agent { "chrome" }
    chain_id { Session::POLYGON_MAINNET }
    message { "aaasadsdasasdsa" }
    signature { "aw32323423423423423432" }
    domain { "localhost" }
  end
end
