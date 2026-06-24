from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
import yt_dlp
import uuid
import os
import asyncio

app = FastAPI()
DOWNLOAD_DIR = "/tmp/vidsave"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)


class URLRequest(BaseModel):
    url: str


class DownloadRequest(BaseModel):
    url: str
    format_id: str


@app.post("/info")
async def get_info(req: URLRequest):
    ydl_opts = {"quiet": True, "no_warnings": True, "skip_download": True}
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = await asyncio.to_thread(ydl.extract_info, req.url, download=False)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {
        "id": str(uuid.uuid4()),
        "title": info.get("title", "Unbekannter Titel"),
        "thumbnailURL": info.get("thumbnail", ""),
        "sourceURL": req.url,
        "formats": _extract_formats(info),
    }


@app.post("/download")
async def download_video(req: DownloadRequest):
    filename = str(uuid.uuid4())
    output_path = os.path.join(DOWNLOAD_DIR, filename)
    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "format": req.format_id,
        "outtmpl": output_path + ".%(ext)s",
        "merge_output_format": "mp4",
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            await asyncio.to_thread(ydl.download, [req.url])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    final_path = output_path + ".mp4"
    if not os.path.exists(final_path):
        for f in os.listdir(DOWNLOAD_DIR):
            if f.startswith(filename):
                final_path = os.path.join(DOWNLOAD_DIR, f)
                break
    return FileResponse(
        path=final_path,
        media_type="video/mp4",
        filename="video.mp4",
        background=_CleanupTask(final_path),
    )


def _extract_formats(info: dict) -> list:
    seen = set()
    result = []
    for f in reversed(info.get("formats") or []):
        if f.get("vcodec", "none") == "none" or not f.get("height"):
            continue
        label = f"{f[\"height\"]}p"
        if label in seen:
            continue
        seen.add(label)
        result.append({"id": f.get("format_id", ""), "label": label, "ext": f.get("ext", "mp4")})
    result.sort(key=lambda x: int(x["label"].replace("p", "")), reverse=True)
    if not result:
        result.append({"id": "best", "label": "Beste Qualitaet", "ext": "mp4"})
    return result


class _CleanupTask:
    def __init__(self, path: str):
        self.path = path

    async def __call__(self, scope, receive, send):
        try:
            os.remove(self.path)
        except FileNotFoundError:
            pass