from abc import ABC, abstractmethod
from typing import Dict, Any, List
from dataclasses import dataclass


@dataclass
class ClassificationInput:
    """Input for document classification."""
    s3_bucket: str
    s3_key: str
    filename: str
    application_id: str


@dataclass
class ClassificationOutput:
    """Output from document classification."""
    document_type: str
    confidence_score: float
    requires_review: bool
    raw_response: Dict[str, Any]


class IClassifier(ABC):
    """Abstract interface for document classifier."""

    @abstractmethod
    def classify(self, input_data: ClassificationInput) -> ClassificationOutput:
        """Classify a single document."""
        pass

    @abstractmethod
    def classify_batch(self, input_data_list: List[ClassificationInput]) -> List[ClassificationOutput]:
        """Classify multiple documents."""
        pass
