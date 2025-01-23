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
  let init_data = {}
  init_data.transactions = {'data': {'total': 0}};
  const [data, setData] = useState(init_data);

  const fetchForeigneExchangeGainData = async() => {
    try {
      const res = await fetchForeigneExchangeGain()
      const res_status = await res.status
      if (res_status == 200) {
        const res_json = await res.json();
        const result = {}
        result.transactions = res_json;
        setData(result);
      }
    } catch (error) {
      console.error(error.message);
    }

  }

  useEffect(() => {
    fetchForeigneExchangeGainData();    
  }, []);

  return (
    <div>
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
                      <tr className="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
                          <th scope="row" className="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                              2024/02/01
                          </th>
                          <td className="px-6 py-4">
                              ドルを円に変換
                          </td>
                          <td className="px-6 py-4">
                              88
                          </td>
                          <td className="px-6 py-4">
                              131.55
                          </td>
                          <td className="px-6 py-4">
                              11577.16
                          </td>
                          <td className="px-6 py-4">
                              12,918
                          </td>
                          <td className="px-6 py-4">
                              +1,341
                          </td>
                      </tr>
                      <tr className="bg-white border-b dark:bg-gray-800 dark:border-gray-700">
                          <th scope="row" className="px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                              2024/04/05
                          </th>
                          <td className="px-6 py-4">
                              ドルを円に変換
                          </td>
                          <td className="px-6 py-4">
                              $72.1
                          </td>
                          <td className="px-6 py-4">
                              133.37
                          </td>
                          <td className="px-6 py-4">
                              ￥9616.61
                          </td>
                          <td className="px-6 py-4">
                              ￥10,930
                          </td>
                          <td className="px-6 py-4">
                              +￥1,313
                          </td>
                      </tr>
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
