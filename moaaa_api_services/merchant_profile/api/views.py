from rest_framework import viewsets, status
from rest_framework.response import Response


class Merchant_profileViewSet(viewsets.ViewSet):
    """API ViewSet for merchant_profile."""

    def list(self, request):
        # TODO: Implement
        return Response([])

    def retrieve(self, request, pk=None):
        # TODO: Implement
        return Response({})

    def create(self, request):
        # TODO: Implement
        return Response({}, status=status.HTTP_201_CREATED)

    def update(self, request, pk=None):
        # TODO: Implement
        return Response({})

    def destroy(self, request, pk=None):
        # TODO: Implement
        return Response(status=status.HTTP_204_NO_CONTENT)
