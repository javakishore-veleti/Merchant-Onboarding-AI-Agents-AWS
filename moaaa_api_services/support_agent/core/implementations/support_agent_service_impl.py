from typing import List, Optional
from ..interfaces.support_agent_service import ISupport_agentService
from ...dao.interfaces.support_agent_repository import ISupport_agentRepository


class Support_agentServiceImpl(ISupport_agentService):
    """Concrete implementation of support_agent service."""

    def __init__(self, repository: ISupport_agentRepository):
        self.repository = repository

    def get_by_id(self, id: str) -> Optional[dict]:
        return self.repository.get_by_id(id)

    def get_all(self) -> List[dict]:
        return self.repository.get_all()

    def create(self, data: dict) -> dict:
        # TODO: Add business logic/validation
        return self.repository.create(data)

    def update(self, id: str, data: dict) -> Optional[dict]:
        # TODO: Add business logic/validation
        return self.repository.update(id, data)

    def delete(self, id: str) -> bool:
        return self.repository.delete(id)
