'use client';

// import { use } from "react";
import { useEffect } from 'react';
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
export default function Home() {
  // // 判定できるようにclassにするべき
  // const [header, setHeader] = useState({});

  // // const res = await fetchSessionsUser(body)
  const fetchForeigneExchangeGainData = async() => {
    try {
      const res = await fetchForeigneExchangeGain()
      const res_status = await res.status
      if (res_status == 200) {
        const res_json = await res.json();
        console.log(res_json);
      }
    } catch (error) {
      console.error(error.message);
    }

  }

  useEffect(() => {
    fetchForeigneExchangeGainData();    
  }, []);

  return (
	  <div className="container">
      <Header />
	  </div>
  );
}
