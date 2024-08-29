# -*- coding: utf-8 -*-
from decentralized.infrastructures.ethereum.ethereum import Ethereum
import time

class OrganizationCreate:
    def __init__(self, ethereum: Ethereum):
        self.ethereum = ethereum

    # , address: str
    def execute(self):
        print("処理を開始します。")
        #　ここでコントらくと作成のじっけん
        #　ここで出力
        time.sleep(10)  # 3秒間スリープ
        print("10秒後に処理が再開されました。")
