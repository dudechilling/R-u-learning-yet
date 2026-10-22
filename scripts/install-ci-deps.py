"""Install exact optional QA dependencies from checksum-verified CRAN sources.

This is CI preparation, not a package runtime dependency or telemetry service.
"""
from __future__ import annotations
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import urllib.error
import urllib.request

PACKAGES = (
    ("rstudioapi", "0.18.0", "9649eef00381d3bde3d96928782e8792d78b9be0a2968e832728b54f5886fdbd"),
    ("palmerpenguins", "0.1.1", "2a40d48ba6c7978fdf2a6daf647ccb39cd17590680138931d11194d3dd1a30b4"),
)

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--library", required=True, type=Path)
    parser.add_argument("--cache", type=Path)
    args = parser.parse_args()
    library = args.library.expanduser().resolve()
    library.mkdir(parents=True, exist_ok=True)
    cache = args.cache.expanduser().resolve() if args.cache else Path(tempfile.mkdtemp(prefix="rulearn-dependencies-"))
    cache.mkdir(parents=True, exist_ok=True)
    for name, version, expected in PACKAGES:
        filename = f"{name}_{version}.tar.gz"
        target = cache / filename
        if not target.exists():
            urls = (f"https://cran.r-project.org/src/contrib/{filename}",
                    f"https://cran.r-project.org/src/contrib/Archive/{name}/{filename}")
            failures = []
            for url in urls:
                try:
                    with urllib.request.urlopen(url, timeout=60) as response:
                        content = response.read(20 * 1024 * 1024 + 1)
                    if len(content) > 20 * 1024 * 1024:
                        raise RuntimeError(f"Oversized dependency archive: {name}")
                    if hashlib.sha256(content).hexdigest() != expected:
                        raise RuntimeError(f"Dependency SHA-256 mismatch: {name} {version}")
                    target.write_bytes(content)
                    break
                except (urllib.error.URLError, TimeoutError) as exc:
                    failures.append(f"{url}: {type(exc).__name__}")
            else:
                raise RuntimeError("Dependency download failed: " + "; ".join(failures))
        if hashlib.sha256(target.read_bytes()).hexdigest() != expected:
            raise RuntimeError(f"Cached dependency SHA-256 mismatch: {target.name}")
        subprocess.run(["Rscript", "--vanilla", "-e",
            "a<-commandArgs(TRUE);install.packages(a[1],repos=NULL,type='source',lib=a[2]);"
            "stopifnot(as.character(packageVersion(a[3],lib.loc=a[2]))==a[4])",
            str(target), str(library), name, version], check=True)
        print(f"Verified and installed {name} {version} SHA256 {expected}", flush=True)

if __name__ == "__main__":
    main()
