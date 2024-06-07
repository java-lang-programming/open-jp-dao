# -*- coding: utf-8 -*-
# 不正のNFT
class InvalidEmployeeAuthorityNFT(Exception):
    def __init__(self, arg=""):
        self.arg = arg
