# -*- coding: utf-8 -*-
class InvalidChainID(Exception):
    def __init__(self, arg=""):
        self.arg = arg
