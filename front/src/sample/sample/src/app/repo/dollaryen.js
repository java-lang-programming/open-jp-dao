const ApiBaseUrl = "http://localhost:3000"

/**
 * @description rails apiに接続してForeigneExchangeGainを取得する
 * @function 
 */
export const fetchForeigneExchangeGain = ()=> {
  return fetch(`${ApiBaseUrl}/apis/dollaryen/foreigne_exchange_gain`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    },
  	mode: 'cors',
  	credentials: 'include'
  })
}
