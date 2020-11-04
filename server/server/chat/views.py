from rest_framework.views import APIView

class IndexView(APIView):
    def get(self, request):
        return Response()
