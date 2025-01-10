import hashlib
import pytest
import requests
import time

from unittest.mock import patch, MagicMock


# TODO do this more elegantly?
# Put fetch_release in a py folder for example?
import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import fetch_release

@pytest.fixture(scope="module")
def retry_config():
    """
    Fixture to define retry configuration.
    """
    return {
        'max_retries': 1, # TODO set to 3 later?
        'retry_delay': 5  # Delay between retries in seconds
    }

def get_output_value(name):
    """
    Retrieve the value of a variable from the GITHUB_OUTPUT file.
    """
    github_output_path = os.environ.get("GITHUB_OUTPUT")

    if github_output_path and os.path.exists(github_output_path):
        with open(github_output_path, "r") as f:
            for line in f:
                # Each line is in the form 'name=value'
                if line.startswith(name + "="):
                    return line.split("=", 1)[1].strip()  # Return the value after '='
    return None

def test_get_all_tags_github(retry_config):
    """
    Test getting all GitHub tags using the GitHub API.
    """
    max_retries = retry_config['max_retries']
    retry_delay = retry_config['retry_delay']

    for _ in range(max_retries):
        try:
            tags = fetch_release.get_all_tags_github()
            # Tags list for a minimal tags check
            tags_to_check = ["2.0.5-0", "2.0.5.rc0-0", "1.5.12-0"]
            assert isinstance(tags, set)
            assert len(tags) >= 30
            assert set(tags_to_check).issubset(tags), f"Not all tags are in the set: {tags_to_check}"
            print("Fetched GitHub tags:", tags)
            return
        except requests.exceptions.RequestException as e:
            print(f"Error fetching tags, retrying... {e}")
            time.sleep(retry_delay)

    pytest.fail("Failed to fetch GitHub tags after multiple retries.")


@pytest.mark.parametrize("version", ("latest", "2.0.5", "1.5.9", "2.0.5.rc0", "2.0.4alpha1"))
@pytest.mark.parametrize("use_default_version", (False, True))
def test_get_micromamba_existing_version(retry_config, version, use_default_version):
    """
    Test fetching existing micromamba stable version.
    """
    max_retries = retry_config['max_retries']
    retry_delay = retry_config['retry_delay']

    for _ in range(max_retries):
        try:
            fetch_release.get_micromamba(version, use_default_version)
            assert get_output_value("MICROMAMBA_NEW_VERSION") == "false"
            assert get_output_value("MICROMAMBA_NEW_PRERELEASE") == None
            assert get_output_value("MICROMAMBA_LATEST") == None
            assert get_output_value("MICROMAMBA_VERSION") == None
            print(f"Fetched micromamba release {version} successfully.")
            return
        except requests.exceptions.RequestException as e:
            print(f"Error fetching micromamba release, retrying... {e}")
            time.sleep(retry_delay)

    pytest.fail(f"Failed to fetch micromamba release info after multiple retries.")

@pytest.mark.parametrize("use_default_version", (False, True))
def test_get_micromamba_non_existing_version(use_default_version):
    """
    Test fetching non existing micromamba version.
    """

    with pytest.raises(requests.exceptions.HTTPError):
        fetch_release.get_micromamba("9.10.5", use_default_version)

#TODO mock test for non existing versions => new_version_1_x, new_version_2_x, new_prerelease

@patch('fetch_release.requests.get') # TODO remove fetch_release?
@patch("fetch_release.subprocess.check_call")
@patch("fetch_release.shutil.copyfile")
def test_get_micromamba_new_2_x_version(mock_get, mock_check_call, mock_copyfile):
    # Mock the response from the Anaconda API
    mock_response = MagicMock()
    mock_response.status_code = 200

    # Mock request content to return a byte string
    mocked_content = b"some random binary data representing a tar.bz2 file"
    mock_response.content = mocked_content

    sha256 = hashlib.sha256()
    sha256.update(mocked_content)
    computed_checksum = sha256.hexdigest()

    mock_response.json.return_value = {
        "distributions": [
            {
                "attrs": {
                    "subdir": "linux-64",
                    "build_number": 1
                },
                "download_url": "https://anaconda-api/conda-forge/micromamba/10.11.12/linux-64/micromamba-10.11.12-1.tar.bz2",
                "sha256": computed_checksum,
                "basename": "linux-64/micromamba-10.11.12-linux-64.tar.bz2",
                "version": "10.11.12"
            },
            {
                "attrs": {
                    "subdir": "linux-aarch64",
                    "build_number": 1
                },
                "download_url": "https://anaconda-api/conda-forge/micromamba/10.11.12/linux-aarch64/micromamba-10.11.12-1.tar.bz2",
                "sha256": computed_checksum,
                "basename": "linux-aarch64/micromamba-10.11.12-linux-aarch64.tar.bz2",
                "version": "10.11.12"
            },
            {
                "attrs": {
                    "subdir": "linux-ppc64le",
                    "build_number": 1
                },
                "download_url": "https://anaconda-api/conda-forge/micromamba/10.11.12/linux-ppc64le/micromamba-10.11.12-1.tar.bz2",
                "sha256": computed_checksum,
                "basename": "linux-ppc64le/micromamba-10.11.12-linux-ppc64le.tar.bz2",
                "version": "10.11.12"
            },
            {
                "attrs": {
                    "subdir": "win-64",
                    "build_number": 1
                },
                "download_url": "https://anaconda-api/conda-forge/micromamba/10.11.12/win-64/micromamba-10.11.12-1.tar.bz2",
                "sha256": computed_checksum,
                "basename": "win-64/micromamba-10.11.12-win-64.tar.bz2",
                "version": "10.11.12"
            },
            {
                "attrs": {
                    "subdir": "osx-64",
                    "build_number": 1
                },
                "download_url": "https://anaconda-api/conda-forge/micromamba/10.11.12/osx-64/micromamba-10.11.12-1.tar.bz2",
                "sha256": computed_checksum,
                "basename": "osx-64/micromamba-10.11.12-osx-64.tar.bz2",
                "version": "10.11.12"
            },
            {
                "attrs": {
                    "subdir": "osx-arm64",
                    "build_number": 1
                },
                "download_url": "https://anaconda-api/conda-forge/micromamba/10.11.12/osx-arm64/micromamba-10.11.12-1.tar.bz2",
                "sha256": computed_checksum,
                "basename": "osx-arm64/micromamba-10.11.12-osx-arm64.tar.bz2",
                "version": "10.11.12"
            }
        ]
    }

    mock_get.return_value = mock_response

    # Mock subprocess.check_call to prevent actual command execution
    mock_check_call.return_value = None  # Simulate a successful call

    # Mock shutil.copyfile to prevent file copying
    #mock_copyfile.return_value = None  # Simulate successful copy
    # Mock shutil.copyfile to simulate copying a valid file
    def mock_copyfile_side_effect(src, dst, follow_symlinks=True):
        # Simulate that the source file exists
        # TODO use different versions and subdirs
        if src == 'micromamba-10.11.12-1-linux-64/bin/micromamba':
            # Simulate successful copy operation
            assert dst == 'releases/micromamba-linux-64'
        else:
            raise FileNotFoundError(f"File {src} not found")

    mock_copyfile.side_effect = mock_copyfile_side_effect

    # Mock existing GitHub tags to simulate the version already being tagged
    with patch.object(fetch_release, 'get_all_tags_github', return_value={'2.0.5-0'}):
        # Run the method with the mocked data
        fetch_release.get_micromamba('10.11.12', False)

        # Check that the `requests.get` method was called as expected
        mock_get.assert_called_once_with("https://api.anaconda.org/release/conda-forge/micromamba/10.11.12")

        # Ensure that subprocess.check_call was called to extract the archive
        mock_check_call.assert_called_once_with(
            ["micromamba", "package", "extract", "micromamba-10.11.12-1-linux-64.tar.bz2", "micromamba-10.11.12-1-linux-64"])

        # Ensure shutil.copyfile is called with the expected paths
        mock_copyfile.assert_called_once_with(
            'micromamba-10.11.12-1-linux-64/bin/micromamba', 'releases/micromamba-linux-64'
        )


        # Check that the `requests.get` method was called as expected
        #mock_get.assert_called_once_with("https://api.anaconda.org/release/conda-forge/micromamba/10.11.12")

        # Ensure that subprocess.check_call was called to extract the archive
        #mock_check_call.assert_called_once_with(
            #["micromamba", "package", "extract", "micromamba-10.11.12-1-linux-64.tar.bz2", "micromamba-10.11.12-1-linux-64"])

        # Ensure shutil.copyfile is called with the expected paths
        #mock_copyfile.assert_called_once_with(
            #'micromamba-10.11.12-1-linux-64/bin/micromamba', 'releases/micromamba-linux-64'
        #)

        assert get_output_value("MICROMAMBA_NEW_VERSION") == "true"



