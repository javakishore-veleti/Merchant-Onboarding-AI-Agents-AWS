from typing import List, Optional
from ..interfaces.document_extraction_repository import IDocument_extractionRepository
from ..models import *


class Document_extractionRepositoryImpl(IDocument_extractionRepository):
    """Concrete implementation of document_extraction repository."""

    def get_by_id(self, id: str) -> Optional[dict]:
        # TODO: Implement
        pass

    def get_all(self) -> List[dict]:
        # TODO: Implement
        pass

    def create(self, data: dict) -> dict:
        # TODO: Implement
        pass

    def update(self, id: str, data: dict) -> Optional[dict]:
        # TODO: Implement
        pass

    def delete(self, id: str) -> bool:
        # TODO: Implement
        pass
