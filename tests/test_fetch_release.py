import pytest
import requests
import time

# TODO do this more elegantly?
# Put fetch_release in a py folder for example?
import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fetch_release import get_all_tags_github, get_micromamba

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
            tags = get_all_tags_github()
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


@pytest.mark.parametrize("version", ("latest", "2.0.5", "2.0.5.rc0", "2.0.4alpha1"))#, "1.5.10"))
@pytest.mark.parametrize("use_default_version", (False, True))
def test_get_micromamba_existing_version(retry_config, version, use_default_version):
    """
    Test fetching existing micromamba stable version.
    """
    max_retries = retry_config['max_retries']
    retry_delay = retry_config['retry_delay']

    for _ in range(max_retries):
        try:
            get_micromamba(version, use_default_version)
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

#@pytest.mark.parametrize("version", ("1.5.10"))
@pytest.mark.parametrize("use_default_version", (False, True))
def test_get_micromamba_existing_1_x(retry_config, use_default_version):
    """
    Test fetching existing micromamba dev or prerelease version.
    """
    max_retries = retry_config['max_retries']
    retry_delay = retry_config['retry_delay']

    for _ in range(max_retries):
        try:
            version = "1.5.10";
            get_micromamba(version, use_default_version)
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
        get_micromamba("9.10.5", use_default_version)

#TODO mock test for non existing versions => new


