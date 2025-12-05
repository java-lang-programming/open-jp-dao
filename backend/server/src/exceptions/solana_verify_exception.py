# -*- coding: utf-8 -*-
from src.exceptions.app_base_exception import AppBaseException


class SolanaVerifyException(AppBaseException):
    status_code = 401

    def __init__(self, errors):
        super().__init__(errors, message="Solana verification failed")
