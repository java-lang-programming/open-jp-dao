class LedgerCsvsController < ApplicationViewController
  include Nav
  before_action :verify, only: [ :index ]

  def index
    headers
    @navs = ledgers_navs(selected: LEDGERS)
  end
end
