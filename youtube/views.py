from django.shortcuts import render, redirect, get_object_or_404
from .models import Video
from .forms import VideoUploadForm

def video_list(request):
    videos = Video.objects.all()
    return render(request, 'videos/video_list.html', {'videos': videos})

def upload_video(request):
    if request.method == 'POST':
        form = VideoUploadForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect('video_list')
    else:
        form = VideoUploadForm()
    return render(request, 'videos/upload_video.html', {'form': form})

def watch_video(request, pk):
    video = get_object_or_404(Video, pk=pk)
    return render(request, 'videos/watch_video.html', {'video': video})