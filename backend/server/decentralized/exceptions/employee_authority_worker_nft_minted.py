# -*- coding: utf-8 -*-
# すでにEmployeeAuthorityWorkerNFTがmint済み
class EmployeeAuthorityWorkerNFTMinted(Exception):
    def __init__(self, arg=""):
        self.arg = arg
