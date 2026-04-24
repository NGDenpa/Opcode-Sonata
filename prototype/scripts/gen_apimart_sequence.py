import argparse
import subprocess
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", required=True, help="Output directory for frames")
    parser.add_argument("--base-prompt", required=True, help="Base prompt shared by all frames")
    parser.add_argument("--frames", type=int, default=12, help="Number of frames")
    parser.add_argument("--size", default="16:9")
    parser.add_argument("--resolution", default="2k")
    parser.add_argument("--prefix", default="fx_frame")
    parser.add_argument("--model", default="gpt-image-2-official")
    parser.add_argument("--quality", default="high")
    parser.add_argument("--output-format", default="png")
    parser.add_argument("--chroma-key", action="store_true")
    parser.add_argument("--key-color", default="0,255,0")
    parser.add_argument("--key-threshold", type=int, default=90)
    parser.add_argument("--key-soften", type=int, default=40)
    args = parser.parse_args()

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    gen_script = Path(__file__).with_name("gen_apimart_image.py")
    if not gen_script.exists():
        raise RuntimeError(f"Missing image script: {gen_script}")

    for i in range(args.frames):
        frame_hint = (
            f"Animation frame {i + 1}/{args.frames}. "
            "Keep same scene composition and silhouette language, only evolve tiny motion: "
            "glow drift, dust particles, subtle scanline shimmer. "
            "No text, no watermark."
        )
        prompt = f"{args.base_prompt}\n{frame_hint}"
        out_path = out_dir / f"{args.prefix}_{i:03d}.png"

        cmd = [
            "python",
            str(gen_script),
            "--prompt",
            prompt,
            "--output",
            str(out_path),
            "--size",
            args.size,
            "--resolution",
            args.resolution,
            "--model",
            args.model,
            "--quality",
            args.quality,
            "--output-format",
            args.output_format,
        ]
        if args.chroma_key:
            cmd.extend([
                "--chroma-key",
                "--key-color",
                args.key_color,
                "--key-threshold",
                str(args.key_threshold),
                "--key-soften",
                str(args.key_soften),
            ])
        subprocess.run(cmd, check=True)
        print(f"[{i + 1}/{args.frames}] {out_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
