# -*- coding: utf-8 -*-


class NotConnectedException(Exception):
    def __init__(self, errors: dict):
        self.errors = errors
