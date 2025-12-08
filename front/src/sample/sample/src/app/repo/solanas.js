const ApiBaseUrl = "http://localhost:3000"

/**
 * @description rails apiに接続してsolanaのphantomでsigninする
 * @function 
 */
export const postSolanasSignin = (body) => {
  return fetch(`${ApiBaseUrl}/apis/solana/signin`, {
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
