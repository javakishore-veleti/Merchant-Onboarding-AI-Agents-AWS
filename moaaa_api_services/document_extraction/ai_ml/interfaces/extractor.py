from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any


class IDocument_extraction(ABC):
    """Abstract interface for document_extraction AI/ML operations."""

    @abstractmethod
    def process(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process input and return results."""
        pass

    @abstractmethod
    def process_batch(self, input_data_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Process multiple inputs and return results."""
        pass
