from django.urls import path
from .views import select_type

urlpatterns = [
    path('type-records/', TypeTListView.as_view(), name='type-records'),
]
