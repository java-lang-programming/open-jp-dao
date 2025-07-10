class TaxReturnsController < ApplicationViewController
  before_action :index, only: [ :index ]

  def index
    headers
    address = @session.address

    calculation = TaxReturns::Calculation.new(address: address, year: Time.current.year)
    @tax_return = calculation.execute
  end
end
