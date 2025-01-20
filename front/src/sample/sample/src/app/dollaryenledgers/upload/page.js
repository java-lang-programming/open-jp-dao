"use client";

import localFont from "next/font/local";
import "./../../globals.css";
import Link from 'next/link';
import { useState } from "react"

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
  const [file, setFile] = useState();
  const [errors, setErrors] = useState();
  // const [targets, setTargets] = useState<UnsignedCertificatesTargets>();

  const onChangeFile = (e) => {
    if (e.target.files) {
      console.log(e.target.files[0])
      setFile(e.target.files[0]);
    }
  };


  // const handleLogout = async()=> {
  //   const res = await fetch(`http://localhost:3000/apis/sessions/signout`, {
  //       method: "POST",
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       mode: 'cors',
  //       credentials: 'include'
  //   });

  //   const verify_status = await res.status
  //   if (verify_status == 201) {
  //     setAddress("")
  //     return
  //   }
  // }


  const onUploadFile = async(e) => {
    e.preventDefault();
    if (!file) {
      return;
    }

    console.log("onUploadFile");
    console.log(file);
    const formData = new FormData();
    formData.append('file', file);
    formData.append('address', '0x00001E868c62FA205d38BeBaB7B903322A4CC89D');
    const apiBaseUrl = "http://localhost:3000"
    try {
      const response = await fetch(`${apiBaseUrl}/apis/dollaryen/transactions/csv_upload`, {
        method: 'POST',
        body: formData,
        mode: 'cors'
      });
      if (response.status !== 201) {
        const json = await response.json();
        setErrors(json);
      }
    } catch (error) {
      console.error(error.message);
    }
  }

  return (
    <form>
      <div>
        <input type="file" onChange={onChangeFile} />
      </div>
      <div>
        <button type="submit" value="csv import" onClick={(e) => onUploadFile(e)}>csv import</button>
      </div>
    </form>
  );
}

