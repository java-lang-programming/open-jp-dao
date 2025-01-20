const ApiBaseUrl = "http://localhost:3000"

/**
 * @description rails apiに接続してheaderに表示するnotificationを取得する
 * @function 
 */
export const fetchNotificationHeader = ()=> {
  return fetch(`${ApiBaseUrl}/apis/notifications/index`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    },
  	mode: 'cors',
  	credentials: 'include'
  })
}
