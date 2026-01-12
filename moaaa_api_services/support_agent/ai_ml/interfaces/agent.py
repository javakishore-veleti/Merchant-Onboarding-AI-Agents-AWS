from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any


class ISupport_agent(ABC):
    """Abstract interface for support_agent AI/ML operations."""

    @abstractmethod
    def process(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process input and return results."""
        pass

    @abstractmethod
    def process_batch(self, input_data_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Process multiple inputs and return results."""
        pass
