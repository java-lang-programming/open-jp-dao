'use client';

// import { use } from "react";
// import { useEffect, useState } from 'react';
// import { SiweMessage } from 'siwe';
// import Link from 'next/link';
// import "./foreign_exchange_gain_index.css";
// import { fetchUser } from "../repo/sessions";
import { fetchForeigneExchangeGain } from "../repo/dollaryen";
import Header from "../components/header";
import Main from "./main";
// import { makeMessage } from "./usecases/singin";


// https://1.x.wagmi.sh/
// https://docs.metamask.io/wallet/how-to/connect/
// https://docs.metamask.io/wallet/reference/eth_requestaccounts/
export default function Home() {
  // 子供でやる必要があるかも。
  // headerの処理が終わるまで待つ

  return (
	  <div className="container">
      <Header />
      <Main />
	  </div>
  );
}
