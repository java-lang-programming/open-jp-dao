# -*- coding: utf-8 -*-
from typing import Dict, List
from src.decentralized.responses.errors import ErrorDict


class AppBaseException(Exception):
    status_code: int = 400

    def __init__(self, errors: Dict[str, List[ErrorDict]], message: str | None = None):
        super().__init__(message or self.__class__.__name__)
        self.errors = errors
