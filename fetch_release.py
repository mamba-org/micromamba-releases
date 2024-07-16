import os
import shutil
import requests
import rich
from pathlib import Path
import hashlib
import subprocess
import sys

from packaging.version import Version

cache = {}

known_subdirs = {
    "linux-64",
    "linux-ppc64le",
    "linux-aarch64",
    "osx-64",
    "osx-arm64",
    "win-64",
}


def get_all_tags_github():
    url = "https://api.github.com/repos/mamba-org/micromamba-releases/tags"
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    tags = [t["name"] for t in r.json()]
    return set(tags)


def extract_with_micromamba(archive, outdir):
    subprocess.check_call(
        ["micromamba", "package", "extract", str(archive), str(outdir)]
    )


def set_output(name, value):
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ.get("GITHUB_OUTPUT"), "a") as fh:
            print(f"{name}={value}\n", file=fh)


def get_micromamba(version, use_default_version):
    url = f"https://api.anaconda.org/release/conda-forge/micromamba/{version}"
    existing_tags = get_all_tags_github()
    print("Getting Anaconda.org API")
    r = requests.get(url, timeout=10)
    r.raise_for_status()

    rj = r.json()
    rich.print(rj)

    all_subdirs = set([d["attrs"]["subdir"] for d in rj["distributions"]])

    if not known_subdirs.issubset(all_subdirs):
        raise ValueError(f"Missing subdirs: {known_subdirs - all_subdirs}")

    all_versions = set([d["version"] for d in rj["distributions"]])
    assert len(all_versions) == 1
    version = all_versions.pop()

    if use_default_version and ((v := Version(version)).is_devrelease or v.is_prerelease):
        print(f"Skipping dev and pre releases version '{version}'")
        set_output("MICROMAMBA_NEW_VERSION", "false")
        return

    all_build = set([d["attrs"]["build_number"] for d in rj["distributions"]])
    build = max(all_build)

    print(f"Existing versions: {existing_tags}")
    if f"{version}-{build}" in existing_tags:
        print("Tag already exists, skipping")
        set_output("MICROMAMBA_NEW_VERSION", "false")
        return

    for d in rj["distributions"]:
        build_number = d["attrs"]["build_number"]
        if build_number != build:
            continue
        buildplat = d["attrs"]["subdir"]

        url = d["download_url"]
        dsum = d["sha256"]

        dplat = d["attrs"]["subdir"]

        # fetch file and extract it
        r = requests.get(f"https:{url}", timeout=10)
        r.raise_for_status()

        path = Path(d["basename"])
        if d["basename"].endswith(".tar.bz2"):
            ext = ".tar.bz2"
        elif d["basename"].endswith(".conda"):
            ext = ".conda"
        dlloc = Path(f"micromamba-{version}-{build_number}-{dplat}{ext}")
        with open(dlloc, "wb") as f:
            f.write(r.content)

        # verify the sha256
        sha256 = hashlib.sha256()
        with open(dlloc, "rb") as f:
            sha256.update(f.read())
        dlsum = sha256.hexdigest()
        if dlsum != dsum:
            raise Exception(f"checksum mismatch, expected {dsum} but was {dlsum}")

        # extract the file
        extract_dir = Path(f"micromamba-{version}-{build_number}-{dplat}")
        extract_with_micromamba(dlloc, extract_dir)

        # move the file to the right place
        if dplat != "win-64":
            binary = extract_dir / "bin" / "micromamba"
        else:
            binary = extract_dir / "Library" / "bin" / "micromamba.exe"

        outdir = Path("releases")
        outdir.mkdir(exist_ok=True)

        outfile = outdir / f"micromamba-{dplat}"
        shutil.copyfile(binary, outfile)
        shutil.copyfile(dlloc, outdir / f"micromamba-{dplat}{ext}")

        # compute the sha256
        sha256 = hashlib.sha256()
        with open(outdir / f"micromamba-{dplat}", "rb") as f:
            sha256.update(f.read())

        with open(outdir / f"micromamba-{dplat}{ext}.sha256", "w") as f:
            f.write(sha256.hexdigest())

        print(sha256.hexdigest())
        shafile = outfile.with_suffix(".sha256")
        with open(shafile, "w") as f:
            f.write(sha256.hexdigest())

    if (v := Version(version)).is_devrelease or v.is_prerelease:
        set_output("MICROMAMBA_NEW_PRERELEASE", "true")
    else:
        set_output("MICROMAMBA_NEW_PRERELEASE", "false")

    set_output("MICROMAMBA_NEW_VERSION", "true")
    set_output("MICROMAMBA_VERSION", f"{version}-{build_number}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        get_micromamba(sys.argv[1], False)
    else:
        get_micromamba("latest", True)
