const ApiBaseUrl = "http://localhost:3000"

/**
 * @description rails apiに接続してnonceを取得する
 * @function 
 */
export const fetchSessionsNonce = ()=> {
  return fetch(`${ApiBaseUrl}/apis/sessions/nonce`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    },
  	mode: 'cors',
  	credentials: 'include'
  })
}

/**
 * @description rails apiに接続してsigninする
 * @function 
 */
export const postSessionsSignin = (body) => {
  return fetch(`${ApiBaseUrl}/apis/sessions/signin`, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json',
    },
    body: body,
    mode: 'cors',
    credentials: 'include'
  })
}

/**
 * @description rails apiに接続してverifyする
 * @function
 */
export const postVerify = () => {
  return fetch(`${ApiBaseUrl}/apis/sessions/verify`, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json',
    },
    mode: 'cors',
    credentials: 'include'
  })
}

/**
 *  @description rails apiに接続してuse情報を取得する
 *
 */
export const fetchUser = () => {
  return fetch(`${ApiBaseUrl}/apis/sessions/user`, {
    method: "GET",
    headers: {
      'Content-Type': 'application/json',
    },
    mode: 'cors',
    credentials: 'include'
  })
}
