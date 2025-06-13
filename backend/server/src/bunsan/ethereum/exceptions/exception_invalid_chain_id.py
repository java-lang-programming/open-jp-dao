# -*- coding: utf-8 -*-
class ExceptionInvalidChainID(Exception):
    def __init__(self, arg=""):
        self.arg = arg
