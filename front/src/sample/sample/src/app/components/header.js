'use client';

import { use } from "react";
import { useEffect, useState } from 'react';
import "./foreign_exchange_gain_index.css";
import { fetchUser } from "../repo/sessions";
import { fetchNotificationHeader } from "../repo/notifications";

export default function Header() {
  // 判定できるようにclassにするべき
  const [header, setHeader] = useState({});

  const fetchSessionUser = async() => {
    try {
      const [user, notification] = await Promise.all([
        fetchUser(),
        fetchNotificationHeader()
      ]);
      const user_status = await user.status
      let header_data = {}
      if (user_status == 200) {
        const user_json = await user.json();
        header_data.user = user_json;
      } else {
      　// エラーの場合の設計
        // エラー
      }

      const notification_status = await notification.status
      if (notification_status == 200) {
        const notification_json = await notification.json();
        //alert(notification_json);
        header_data.notification = notification_json;
      } else {
        // エラーの場合の設計
        // エラー
      }


      setHeader(header_data)
      //console.log(res);
    } catch (err) {

      //console.error(err.message);
    }
  }

  useEffect(() => {
    fetchSessionUser();    
  }, []);

  return (
    <div>
      <header>
        <div className="header1">
          <div>
            <a href="#" className="header1_site_name">EKISA</a>
          </div>

          <nav
            className="header1_nav">
            <div>
              <button className="btn_sign">ログアウト</button>
            </div>
          </nav>
        </div>

        <div className="header2">
          <div>
            <ul className="header2_nav">
              <li>
                <a href="#"
                  className="header2_nav_li">Home</a>
              </li>
              <li>
                <a href="#"
                  className="header2_nav_li">お知らせ・ご案内</a>
              </li>
            </ul>
          </div>
        </div>
          {
            (header.user) && (
            <div className="header3">
              <div className="header3_item">{ header.user.address }</div>
              <div className="header3_item">{ header.user.network }</div>
              <div className="header3_item">最終ログイン:{ header.user.last_login }</div>
            </div>
            )
          }
      </header>
      {
        (header.notification) && (
          <section className="information">
            <p>{ header.notification.notification.message }</p>
          </section>
        )

      }
    </div>
  );
}
