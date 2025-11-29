# -*- coding: utf-8 -*-


class SolanaVerifyException(Exception):
    def __init__(self, errors: dict):
        self.errors = errors
