from typing import List, Optional
from ..interfaces.application_profile_service import IApplication_profileService
from ...dao.interfaces.application_profile_repository import IApplication_profileRepository


class Application_profileServiceImpl(IApplication_profileService):
    """Concrete implementation of application_profile service."""

    def __init__(self, repository: IApplication_profileRepository):
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
