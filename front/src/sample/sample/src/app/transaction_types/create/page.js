"use client";

import localFont from "next/font/local";
import "./../../globals.css";
import Link from 'next/link';
import { ApiBaseUrl } from "../../repo/url_base";
import React, {useEffect, useState} from 'react';

const geistSans = localFont({
  src: "./../../fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./../../fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export default function Home() {
  const [transactionTypes, setTransactionTypes] = useState({});
  const [errors, setErrors] = useState({});
  const [selectedTransactionType, setSelectedTransactionType] = useState({});

  const currentDate = new Date().toLocaleDateString("ja-JP", {year: "numeric",month: "2-digit",
   day: "2-digit"}).replaceAll('/', '-');

  const [selectedDate, setSelectedDate] = useState(currentDate);
  const [depositQuantity, setDepositQuantity] = useState(0);
  const [rate, setRate] = useState(0);

  // 現在日付を取得
  // apis/transaction_types
  const fetchTransactionTypes = async() => {
    try {
      const response = await fetch(`${ApiBaseUrl}/apis/transaction_types`, {
        method: 'GET',
        mode: 'cors',
        credentials: 'include',
      });
      const json = await response.json();
      if (response.status === 200) {
        console.log(json["transaction_types"]);
        setTransactionTypes(json);
      } else {
        setErrors(json);
      }
    } catch (error) {
      console.error(error.message);
    }
  }

  const changeTransactionType = (e)=> {
    const transactionType = transactionTypes.transaction_types.find((transaction_type) => transaction_type.id == e);
    setSelectedTransactionType(transactionType);
  }

  const changeDate = (e) => {
    setSelectedDate(e);
  }

  const onClickAutoInput = async() => {
    try {
      const response = await fetch(`${ApiBaseUrl}/apis/dollar_yens?date=${selectedDate}`, {
        method: 'GET',
        mode: 'cors',
        credentials: 'include',
      });
      const json = await response.json();
      console.log(json);
      if (response.status === 200) {
        const rate = json["dollar_yens"][0]["dollar_yen_nakane"];
        console.log(rate);
        setRate(Number(rate));
        //setTransactionTypes(json);
      } else {
        setErrors(json);
      }
    } catch (error) {
      console.error(error.message);
    }
    // setRate(100.00)
  }

  const onChangeEventDepositRate = (e) => {
    setRate(Number(e));
  }

  const onChangeEventDepositQuantity = (e) => {
    setDepositQuantity(Number(e));
  }

  const onClickSubmit = async(e) => {
    e.preventDefault()
    let obj = { date: selectedDate, transaction_type_id: selectedTransactionType.id}
    console.log(obj);
    if (selectedTransactionType.kind == 1) {
      obj.deposit_rate = rate;
      obj.deposit_quantity = depositQuantity;
    } else if (selectedTransactionType.kind == 2) {
      obj.withdrawal_quantity = 0;
      obj.exchange_en = 0;
    }
    const body = JSON.stringify(obj);

    const res = await fetch(`http://localhost:3000/apis/dollaryen/transactions`, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
      mode: 'cors',
      credentials: 'include'
    });

  }

  // 2回呼ばれているような。。。
  useEffect(() => {
    console.log("call")
    fetchTransactionTypes()
  },[])

  return (
    <div>
      <p>取引種別作成</p>
      <form action="" method="get" class="form-example">
        <div>
          <label for="start">取引日</label>
          <br/>
          <input type="date" id="start" name="trip-start" value={ selectedDate } onChange={e => changeDate(e.target.value)}/>
        </div>
        <label for="pet-select">取引内容</label>
        <br/>
        {transactionTypes.transaction_types != null && (
          <select 
            value={selectedTransactionType.id}
            onChange={e => changeTransactionType(e.target.value)}>
            {transactionTypes.transaction_types.map((item, index) => (
             <option key={item.id} value={item.id}>{item.name}</option>
            ))}
          </select>
        )}
        {(selectedTransactionType !== null && selectedTransactionType.kind === 1) && (
          <div id="deposit">
            <h2>預入</h2>
            <div>
              <label for="name">数量米ドル</label>
              <input type="number" id="name" name="dollar" maxLength="8" size="10" value={depositQuantity} onChange={e => onChangeEventDepositQuantity(e.target.value)}/>
            </div>
            <div>
              <label for="name">レート</label>
              <input type="number" id="rate" name="rate" maxLength="8" size="10" value={rate} onChange={e => onChangeEventDepositRate(e.target.value)} />
              <input type="button" value="自動入力" onClick={onClickAutoInput}/>
            </div>
          </div>
        )}
        {(selectedTransactionType !== null && selectedTransactionType.kind === 2) && (
          <div id="with_draw">
            <h2>払出</h2>
            <div>
              <label for="name">数量米ドル</label>
              <input type="text" id="name" name="dollar" maxLength="8" size="10" />
            </div>
          </div>
        )}
        <div class="form-example">
          <input type="submit" value="登録" onClick={onClickSubmit}/>
        </div>
      </form>
    </div>
  );
}
