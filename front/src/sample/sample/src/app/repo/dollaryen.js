const ApiBaseUrl = "http://localhost:3000"

/**
 * @description rails apiに接続してtransactionsを取得する
 * @function 
 */
export const fetchTransactions = () => {
  return fetch(`${ApiBaseUrl}/apis/dollaryen/transactions`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    },
    mode: 'cors',
    credentials: 'include'
  }) 
}

/**
 * @description rails apiに接続してForeigneExchangeGainを取得する
 * @function 
 */
export const fetchForeigneExchangeGain = (year) => {
  let query = ""
  if (year) {
    query = "?year=" + year
  }
  return fetch(`${ApiBaseUrl}/apis/dollaryen/foreigne_exchange_gain${query}`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    },
  	mode: 'cors',
  	credentials: 'include'
  })
}

/**
 * @description rails apiに接続してtransactions csv importを実行します
 * @function 
 */
export const postDollaryensTransactionsCsvImport = (body) => {
  return fetch(`${ApiBaseUrl}/apis/dollaryen/transactions/csv_import`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: body,
    mode: 'cors',
    credentials: 'include'
  })
}

export const downloadCsvExport = `${ApiBaseUrl}/apis/dollaryen/downloads/csv_export`
export const downloadCsvImport = `${ApiBaseUrl}/apis/dollaryen/downloads/csv_import`

