const ApiBaseUrl = "http://localhost:3000"

/**
 * @description rails apiに接続してnonceを取得する
 * @function 
 */
export const fetchSessionsNonce = ()=> {
  return fetch(`/apis/sessions/nonce`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    }
  })
}

/**
 * @description rails apiに接続してsigninする
 * @function 
 */
export const postSessionsSignin = (body) => {
  return fetch(`/apis/sessions/signin`, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
    },
    body: body,
    // mode: 'cors',
    // credentials: 'include'
  })
}
