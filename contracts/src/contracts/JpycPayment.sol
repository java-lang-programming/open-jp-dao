// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract JpycPayment {
    address public treasury; // 運営の受け取り用アドレス
    IERC20 public jpyc;     // 変数名をjpycに変更

    // 1ヶ月の価格：330 JPYC (18進数なので 10の18乗を掛ける)
    uint256 public pricePerMonth = 330 * 10**18;

    // 30日を秒単位で定義
    uint256 public constant MONTH_DURATION = 30 days;

    // ユーザーごとの有効期限（Unixタイムスタンプ）
    mapping(address => uint256) public userExpiry;

    // 決済完了時に発行されるログ
    event SubscriptionPaid(address indexed user, uint256 amount, uint256 duration);

    constructor(address _jpyc, address _treasury) {
        jpyc = IERC20(_jpyc);
        treasury = _treasury;
    }

    // 1ヶ月分(例: 330 jpy)を支払う関数
    function payOneMonth() external {
        require(jpyc.transferFrom(msg.sender, treasury, pricePerMonth), "Transfer failed");

        // 有効期限の更新ロジック
        if (userExpiry[msg.sender] > block.timestamp) {
            // 期限内なら今の期限に加算
            userExpiry[msg.sender] += MONTH_DURATION;
        } else {
            // 期限切れなら現在時刻から30日
            userExpiry[msg.sender] = block.timestamp + MONTH_DURATION;
        }

        emit SubscriptionPaid(msg.sender, pricePerMonth, MONTH_DURATION);
    }

    // サービス側から「有効か」を確認する関数
    function isActive(address _user) public view returns (bool) {
        return userExpiry[_user] > block.timestamp;
    }
}
