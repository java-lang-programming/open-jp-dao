# -*- coding: utf-8 -*-


class InvalidChainException(Exception):
    def __init__(self, errors: dict):
        self.errors = errors
