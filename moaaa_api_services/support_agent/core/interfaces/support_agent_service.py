from abc import ABC, abstractmethod
from typing import List, Optional


class ISupport_agentService(ABC):
    """Abstract interface for support_agent service."""

    @abstractmethod
    def get_by_id(self, id: str) -> Optional[dict]:
        pass

    @abstractmethod
    def get_all(self) -> List[dict]:
        pass

    @abstractmethod
    def create(self, data: dict) -> dict:
        pass

    @abstractmethod
    def update(self, id: str, data: dict) -> Optional[dict]:
        pass

    @abstractmethod
    def delete(self, id: str) -> bool:
        pass
