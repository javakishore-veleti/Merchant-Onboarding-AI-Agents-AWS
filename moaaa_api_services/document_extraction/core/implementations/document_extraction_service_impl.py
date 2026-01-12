from typing import List, Optional
from ..interfaces.document_extraction_service import IDocument_extractionService
from ...dao.interfaces.document_extraction_repository import IDocument_extractionRepository


class Document_extractionServiceImpl(IDocument_extractionService):
    """Concrete implementation of document_extraction service."""

    def __init__(self, repository: IDocument_extractionRepository):
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
