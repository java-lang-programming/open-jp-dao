'use client';

// import { use } from "react";
import { useEffect, useState } from 'react';
// import { SiweMessage } from 'siwe';
// import Link from 'next/link';
import "./foreign_exchange_gain_index.css";
// import { fetchUser } from "../repo/sessions";
import { fetchForeigneExchangeGain } from "../repo/dollaryen";
import Header from "../components/header";
// import { makeMessage } from "./usecases/singin";


// https://1.x.wagmi.sh/
// https://docs.metamask.io/wallet/how-to/connect/
// https://docs.metamask.io/wallet/reference/eth_requestaccounts/
export default function Main() {
  // 関数にする usecases/foreign_exchange_gain
  let date = new Date();
  let current_year = date.getFullYear();
  const years = [];
  for (let i = 0; i < 5; i++) {
    let temp_year = current_year - i
    years.push(temp_year);
  }



  let init_data = {'transactions': {'data': {'total': 0} }}
  const [data, setData] = useState(init_data);

  const fetchForeigneExchangeGainData = async(year) => {
    try {
      const res = await fetchForeigneExchangeGain(year)
      const res_status = await res.status
      if (res_status == 200) {
        const res_json = await res.json();
        const result = {}
        result.transactions = res_json;
        result.year = year
        console.log(result);
        setData(result);
      }
    } catch (error) {
      // ここでエラーをキャッチすること
      alert(error);
      console.error(error.message);
    }
  }

  const onChangeYear = (e) => {
    const year = e.target.value;
    fetchForeigneExchangeGainData(year);
  }

  // onClick

  useEffect(() => {
    fetchForeigneExchangeGainData(current_year);    
  }, []);

  return (
    <div>
      <section id="nendo">
        <label for="countries" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">為替差益を表示したい年度を選択してください</label>
        <select onChange={(e) => { onChangeYear(e) }} id="countries" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
        { (years.map((year, index) =>
          <option value={ year }>{ year }</option>
        )) }
        </select>
      </section>
      { (data.transactions.date) && (
        <div>
          <br/>
          <h2 className="text-base/7 font-semibold text-indigo-600">{ data.year }年為替差益<a href="./">▶️</a></h2>
          <p className="mt-2 text-pretty text-4xl font-semibold tracking-tight text-gray-900 sm:text-5xl lg:text-balance">{ data.transactions.foreign_exchange_gain }円</p>
          <p clasclassNames="mt-6 text-lg/8 text-gray-600">*確定申告について</p>
        </div>
      )}
      { (data.transactions.data.total > 0) && (
        <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
          <div className="relative overflow-x-auto">
              <table className="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
                  <thead className="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
                      <tr>
                          <th scope="col" className="px-6 py-3">
                              取引日
                          </th>
                          <th scope="col" className="px-6 py-3">
                              取引種別
                          </th>
                          <th scope="col" className="px-6 py-3">
                              数量米ドル
                          </th>
                          <th scope="col" className="px-6 py-3">
                              レート(ドル/円)
                          </th>
                          <th scope="col" className="px-6 py-3">
                              円換算(円)
                          </th>
                          <th scope="col" className="px-6 py-3">
                              出金(円)
                          </th>
                          <th scope="col" className="px-6 py-3">
                              差益(円)
                          </th>
                      </tr>
                  </thead>
                  <tbody>
                      { (data.transactions.data.dollaryen_transactions.map((dollaryen_transaction, index) =>
                      <tr className="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
                          <th scope="row" className="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                              {dollaryen_transaction.date}
                          </th>
                          <td className="px-6 py-4">
                              {dollaryen_transaction.transaction_type_name}
                          </td>
                          <td className="px-6 py-4">
                              {dollaryen_transaction.withdrawal_quantity}
                          </td>
                          <td className="px-6 py-4">
                              ${dollaryen_transaction.withdrawal_rate}
                          </td>
                          <td className="px-6 py-4">
                              ${dollaryen_transaction.withdrawal_en}
                          </td>
                          <td className="px-6 py-4">
                              ￥{dollaryen_transaction.exchange_en}
                          </td>
                          <td className="px-6 py-4">
                              ￥{dollaryen_transaction.exchange_difference}
                          </td>
                      </tr>
                      )) }
                  </tbody>
              </table>
          </div>
        </div>
      )}
      { (data.transactions) && (data.transactions.data.total === 0) && (
        <p>取引データがありません。</p>
      )}  
	  </div>
  );
}
