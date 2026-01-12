from typing import List, Optional
from ..interfaces.merchant_profile_repository import IMerchant_profileRepository
from ..models import *


class Merchant_profileRepositoryImpl(IMerchant_profileRepository):
    """Concrete implementation of merchant_profile repository."""

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
