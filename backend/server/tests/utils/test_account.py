# -*- coding: utf-8 -*-
import os

class TestAccount:

    Owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    UserAddress_1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

    def __init__(self):
        self._owner_address = os.getenv("OWNER_ADDRESS", TestAccount.Owner)
        self._user_address_1 = os.getenv("USER_ADDRESS_1", TestAccount.UserAddress_1)

    @property
    def owner_address(self) -> str:
        return self._owner_address

    @property
    def user_address_1(self) -> str:
        return self._user_address_1
