"use client";

import localFont from "next/font/local";
// import "./../globals.css";
import Link from 'next/link';
import React, {useEffect, useState} from 'react';
import { fetchTransactions, downloadCsvExport, downloadCsvImport } from "../repo/dollaryen";


const geistSans = localFont({
  src: "./../fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./../fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export default function Home() {
  const [total, setTotal] = useState(0);
  const [list, setList] = useState([]);
  const [errors, setErrors] = useState();


  // address=0x00001E868c62FA205d38BeBaB7B903322A4CC89Dz
  const fetchList = async() => {
    try {
      const response = await fetchTransactions()
      const json = await response.json();
      if (response.status === 200) {
        setTotal(json["total"]);
        setList(json["dollaryen_transactions"]);
      } else {
        setErrors(json);
      }
    } catch (error) {
      console.error(error.message);
    }
  }


  useEffect(() => {
    fetchList()
  },[])


  return (
    <div>
      <p>外貨預金元帳ドル円一覧</p>
      <br/>
      <Link href="/transaction_types/create">取引種別作成</Link><br/>
      <Link href="/dollaryenledgers/create">外貨預金元帳ドル円作成</Link><br/>
      <Link href="/dollaryenledgers/1">外貨預金元帳ドル円詳細</Link><br/>
      <Link href="/dollaryenledgers/upload">外貨預金元帳ドル円csvアップロード</Link><br />
      <Link href={downloadCsvExport}>外貨預金元帳ドル円csv exportダウンロード</Link><br/>
      <Link href={downloadCsvImport}>外貨預金元帳ドル円csv importダウンロード</Link>
      <hr />
      <table border="2">
        <thead>
          <tr>
            <th scope="col" rowSpan="2">No</th>
            <th scope="col" rowSpan="2">取引日</th>
            <th scope="col" rowSpan="2">取引種類</th>
            <th scope="col" colSpan="3">預かり入れ</th>
            <th scope="col" colSpan="3">払出</th>
            <th scope="col" colSpan="3">残帳簿価格</th>
            <th scope="col" colSpan="2" rowSpan="2">アクション</th>
          </tr>
          <tr>
            <th scope="col">数量米ドル </th>
            <th scope="col">レート</th>
            <th scope="col">円換算</th>
            <th scope="col">数量米ドル </th>
            <th scope="col">レート</th>
            <th scope="col">円換算</th>
            <th scope="col">数量米ドル </th>
            <th scope="col">  レート</th>
            <th scope="col">円換算</th>
          </tr>
        </thead>
        <tbody>
          {list.length > 0 && list.map((transaction, index) =>
            <tr key={index}>
              <th scope="row">{index + 1}</th> 
              <th scope="row">{transaction.date}</th>
              <th scope="row">{transaction.transaction_type_name}</th>
              <th scope="row">{transaction.deposit_quantity}</th>
              <td>{transaction.deposit_rate}</td>
              <td>{transaction.deposit_en}</td>
              <td>{transaction.withdrawal_quantity}</td>
              <td>{transaction.withdrawal_rate}</td>
              <td>{transaction.withdrawal_en}</td>
              <td>{transaction.balance_quantity}</td>
              <td>{transaction.balance_rate}</td>
              <td>{transaction.balance_en}</td>
              <td><input type="button" value="編集"/></td>
              <td><input type="button" value="削除"/></td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
