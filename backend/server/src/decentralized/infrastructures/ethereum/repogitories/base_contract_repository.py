# -*- coding: utf-8 -*-

import abc
import json


class BaseContractRepository(metaclass=abc.ABCMeta):
    def load_artifacts_json(self, json_path: str):
        with open(json_path, "r") as j:
            return json.load(j)
        return None

    @abc.abstractmethod
    def abi(self, json_path: str) -> None:
        raise NotImplementedError()
