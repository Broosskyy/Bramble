#!/usr/bin/env python3
import base64
import json
import mimetypes
import os
import pathlib
import sys
import time
import urllib.error
import urllib.request
import zipfile

API_BASE = "https://api.meshy.ai/openapi/v1"
TERMINAL = {"SUCCEEDED", "FAILED", "CANCELED"}


def fail(message: str, code: int = 1):
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def request_json(method: str, url: str, api_key: str, payload=None):
    data = None
    headers = {"Authorization": f"Bearer {api_key}"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            body = res.read().decode("utf-8")
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        fail(f"Meshy HTTP {exc.code}: {body}")
    except urllib.error.URLError as exc:
        fail(f"Meshy network error: {exc}")


def bytes_to_data_uri(name: str, raw: bytes) -> str:
    mime, _ = mimetypes.guess_type(name)
    mime = mime or "image/png"
    return f"data:{mime};base64,{base64.b64encode(raw).decode('ascii')}"


def reference_to_data_uri(spec: str) -> str:
    if "::" in spec:
        archive_name, inner_name = spec.split("::", 1)
        archive = pathlib.Path(archive_name)
        if not archive.exists():
            fail(f"Reference archive missing: {archive}")
        try:
            with zipfile.ZipFile(archive, "r") as zf:
                raw = zf.read(inner_name)
        except KeyError:
            fail(f"Reference '{inner_name}' not found inside {archive}")
        except zipfile.BadZipFile:
            fail(f"Invalid ZIP archive: {archive}")
        return bytes_to_data_uri(inner_name, raw)

    path = pathlib.Path(spec)
    if not path.exists():
        fail(f"Reference image missing: {path}")
    return bytes_to_data_uri(path.name, path.read_bytes())


def download(url: str, target: pathlib.Path):
    target.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(url, timeout=120) as res:
        target.write_bytes(res.read())


def main():
    if len(sys.argv) != 2:
        fail("Usage: meshy_generate.py <job.json>")

    api_key = os.environ.get("MESHY_API_KEY")
    if not api_key:
        fail("MESHY_API_KEY secret is missing.")

    job_path = pathlib.Path(sys.argv[1])
    if not job_path.exists():
        fail(f"Job file does not exist: {job_path}")

    job = json.loads(job_path.read_text(encoding="utf-8"))
    job_id = job["id"]

    refs = job.get("references", [])
    if not 1 <= len(refs) <= 4:
        fail("Meshy Multi-Image requires 1 to 4 reference images.")

    image_urls = [reference_to_data_uri(p) for p in refs]

    payload = {
        "image_urls": image_urls,
        "ai_model": job.get("ai_model", "meshy-7.1"),
        "geometry_resolution": job.get("geometry_resolution", "standard"),
        "should_texture": job.get("should_texture", True),
        "enable_pbr": job.get("enable_pbr", True),
        "texture_resolution": job.get("texture_resolution", "2k"),
        "should_remesh": job.get("should_remesh", False),
        "pose_mode": job.get("pose_mode", "a-pose"),
        "image_enhancement": job.get("image_enhancement", False),
        "remove_lighting": job.get("remove_lighting", True),
        "multi_view_thumbnails": True,
        "target_formats": ["glb"],
    }

    if "target_polycount" in job:
        payload["target_polycount"] = int(job["target_polycount"])
    if "topology" in job:
        payload["topology"] = job["topology"]

    if job.get("use_reference_images_for_texture", False):
        payload["texture_image_urls"] = image_urls
    else:
        texture_prompt = job.get("texture_prompt")
        if texture_prompt:
            payload["texture_prompt"] = texture_prompt

    print(f"Submitting Meshy job '{job_id}' with {len(image_urls)} views...")
    created = request_json("POST", f"{API_BASE}/multi-image-to-3d", api_key, payload)
    task_id = created.get("result")
    if not task_id:
        fail(f"Meshy did not return a task id: {created}")

    out_dir = pathlib.Path("meshy/output") / job_id
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "submission.json").write_text(
        json.dumps({"task_id": task_id, "job": job}, indent=2),
        encoding="utf-8",
    )

    print(f"Task: {task_id}")
    deadline = time.time() + int(job.get("timeout_seconds", 1800))
    final = None

    while time.time() < deadline:
        task = request_json("GET", f"{API_BASE}/multi-image-to-3d/{task_id}", api_key)
        status = task.get("status", "UNKNOWN")
        progress = task.get("progress", 0)
        print(f"Meshy status={status} progress={progress}%")
        if status in TERMINAL:
            final = task
            break
        time.sleep(15)

    if final is None:
        fail(f"Timed out waiting for Meshy task {task_id}. The remote task may still be running.")

    (out_dir / "task.json").write_text(json.dumps(final, indent=2), encoding="utf-8")

    if final.get("status") != "SUCCEEDED":
        fail(f"Meshy task ended with {final.get('status')}: {final.get('task_error')}")

    glb_url = (final.get("model_urls") or {}).get("glb")
    if not glb_url:
        fail("Meshy succeeded but returned no GLB URL.")
    download(glb_url, out_dir / f"{job_id}.glb")

    thumbnail = final.get("thumbnail_url")
    if thumbnail:
        download(thumbnail, out_dir / "preview.png")

    thumbs = final.get("thumbnail_urls") or {}
    for view, url in thumbs.items():
        if url:
            download(url, out_dir / f"preview_{view}.png")

    meta = {
        "task_id": task_id,
        "status": final.get("status"),
        "consumed_credits": final.get("consumed_credits"),
        "ai_model": payload["ai_model"],
        "geometry_resolution": payload["geometry_resolution"],
        "texture_resolution": payload["texture_resolution"],
        "pose_mode": payload["pose_mode"],
        "texture_reference_mode": job.get("use_reference_images_for_texture", False),
    }
    (out_dir / "result.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"Done: {out_dir}")
    print(f"Consumed credits: {final.get('consumed_credits', 'unknown')}")


if __name__ == "__main__":
    main()
