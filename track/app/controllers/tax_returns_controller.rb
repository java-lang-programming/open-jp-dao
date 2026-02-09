# 確定申告
class TaxReturnsController < ApplicationViewController
  include Nav

  before_action :verify, only: [ :index ]

  def index
    headers
    address = @session.address
    @navs = ledgers_navs(selected: TAX_RESULT)
    @setting = address.setting

    calculation = TaxReturns::Calculation.new(address: address, year: address.setting.default_year)
    @tax_return = calculation.execute
  end
end
