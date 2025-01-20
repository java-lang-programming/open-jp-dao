import localFont from "next/font/local";
import "./../../globals.css";
import Link from 'next/link';

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
  return (
    <div>
      <p>ドル円create</p>
    </div>
  );
}
