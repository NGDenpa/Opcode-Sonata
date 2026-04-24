import argparse
import base64
import os
import time
from pathlib import Path

import requests
from PIL import Image


def try_save_image_from_item(session: requests.Session, item: dict, out_path: Path) -> bool:
    if item.get("b64_json"):
        out_path.write_bytes(base64.b64decode(item["b64_json"]))
        return True
    if item.get("url"):
        img_resp = session.get(item["url"], timeout=180)
        img_resp.raise_for_status()
        out_path.write_bytes(img_resp.content)
        return True
    return False


def apply_green_screen_key(
    image_path: Path,
    key_r: int,
    key_g: int,
    key_b: int,
    threshold: int,
    soften: int,
) -> None:
    img = Image.open(image_path).convert("RGBA")
    px = img.load()
    w, h = img.size

    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            dr = abs(r - key_r)
            dg = abs(g - key_g)
            db = abs(b - key_b)
            dist = dr + dg + db

            if dist <= threshold:
                px[x, y] = (r, g, b, 0)
            elif soften > 0 and dist <= threshold + soften:
                # Edge feather: linear alpha fade
                t = (dist - threshold) / float(soften)
                new_a = int(max(0, min(255, a * t)))
                px[x, y] = (r, g, b, new_a)

    img.save(image_path, format="PNG")


def extract_first_item(body):
    if not isinstance(body, dict):
        return None
    items = body.get("data")
    if isinstance(items, list) and items and isinstance(items[0], dict):
        return items[0]
    return None


def poll_task(session: requests.Session, headers: dict, task_id: str, timeout_sec: int = 300):
    start = time.time()
    status_url = f"https://api.apimart.ai/v1/tasks/{task_id}"
    while time.time() - start < timeout_sec:
        resp = session.get(status_url, headers=headers, params={"language": "en"}, timeout=60)
        if resp.status_code >= 400:
            time.sleep(2.5)
            continue
        body = resp.json()
        if not isinstance(body, dict):
            time.sleep(2.5)
            continue
        data = body.get("data")
        if not isinstance(data, dict):
            time.sleep(2.5)
            continue
        status = str(data.get("status", "")).lower()
        if status in ("pending", "submitted", "queued", "processing", "running", "in_progress"):
            time.sleep(2.5)
            continue
        return body
    raise RuntimeError(f"Timed out waiting for task_id={task_id}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--size", default="16:9")
    parser.add_argument("--resolution", default="2k")
    parser.add_argument("--model", default="gpt-image-2-official")
    parser.add_argument("--quality", default="high")
    parser.add_argument("--background", default="auto")
    parser.add_argument("--moderation", default="auto")
    parser.add_argument("--output-format", default="png")
    parser.add_argument("--output-compression", type=int, default=None)
    parser.add_argument("--chroma-key", action="store_true")
    parser.add_argument("--key-color", default="0,255,0")
    parser.add_argument("--key-threshold", type=int, default=90)
    parser.add_argument("--key-soften", type=int, default=40)
    args = parser.parse_args()

    token = os.environ.get("APIMART_TOKEN")
    if not token:
        raise RuntimeError("Missing APIMART_TOKEN environment variable.")

    url = "https://api.apimart.ai/v1/images/generations"
    payload = {
        "model": args.model,
        "prompt": args.prompt,
        "n": 1,
        "size": args.size,
        "resolution": args.resolution,
        "quality": args.quality,
        "background": args.background,
        "moderation": args.moderation,
        "output_format": args.output_format,
    }
    if args.output_compression is not None:
        payload["output_compression"] = args.output_compression
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    session = requests.Session()
    session.trust_env = False
    response = session.post(url, json=payload, headers=headers, timeout=180)
    response.raise_for_status()
    body = response.json()
    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    first = extract_first_item(body)
    if not first:
        raise RuntimeError(f"Unexpected API response: {body}")

    if try_save_image_from_item(session, first, out_path):
        if args.chroma_key:
            kr, kg, kb = [int(v.strip()) for v in args.key_color.split(",")]
            apply_green_screen_key(out_path, kr, kg, kb, args.key_threshold, args.key_soften)
        print(str(out_path))
        return 0

    task_id = first.get("task_id")
    if task_id:
        final_body = poll_task(session, headers, task_id)
        task_data = final_body.get("data") if isinstance(final_body, dict) else None
        if isinstance(task_data, dict):
            result = task_data.get("result") or {}
            images = result.get("images") or []
            if images and isinstance(images[0], dict):
                urls = images[0].get("url")
                if isinstance(urls, list) and urls and isinstance(urls[0], str):
                    img_resp = session.get(urls[0], timeout=180)
                    img_resp.raise_for_status()
                    out_path.write_bytes(img_resp.content)
                    if args.chroma_key:
                        kr, kg, kb = [int(v.strip()) for v in args.key_color.split(",")]
                        apply_green_screen_key(out_path, kr, kg, kb, args.key_threshold, args.key_soften)
                    print(str(out_path))
                    return 0
                if try_save_image_from_item(session, images[0], out_path):
                    if args.chroma_key:
                        kr, kg, kb = [int(v.strip()) for v in args.key_color.split(",")]
                        apply_green_screen_key(out_path, kr, kg, kb, args.key_threshold, args.key_soften)
                    print(str(out_path))
                    return 0
        raise RuntimeError(f"Task completed but no image payload found: {final_body}")

    raise RuntimeError(f"No image payload and no task_id in response: {body}")


if __name__ == "__main__":
    raise SystemExit(main())
