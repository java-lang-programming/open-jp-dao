# -*- coding: utf-8 -*-


class InvalidFormatAddressException(Exception):
    def __init__(self, errors: dict):
        self.errors = errors
