# -*- coding: utf-8 -*-
from typing import Dict, List
from src.decentralized.responses.errors import ErrorDict


class SolanaVerifyException(Exception):
    def __init__(self, errors: Dict[str, List[ErrorDict]]):
        super().__init__("Solana verification failed")
        self.errors = errors
