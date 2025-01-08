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


@pytest.mark.parametrize("version", ("latest", "2.0.5"))#, "1.5.10"))
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

#TODO add a test with use_default_version = False
@pytest.mark.parametrize("version", ("2.0.5.rc0", "2.0.4alpha1"))
def test_get_micromamba_existing_dev_or_prerelease(retry_config, version):
    """
    Test fetching existing micromamba dev or prerelease version.
    """
    max_retries = retry_config['max_retries']
    retry_delay = retry_config['retry_delay']

    for _ in range(max_retries):
        try:
            get_micromamba(version, use_default_version = True)
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


#def test_get_micromamba_default_version(retry_config):
    #"""
    #Test fetching the default (latest) version of micromamba from Anaconda API.
    #This tests the `use_default_version=True` scenario.
    #"""
    #max_retries = retry_config['max_retries']
    #retry_delay = retry_config['retry_delay']

    #for _ in range(max_retries):
        #try:
            #get_micromamba("latest", use_default_version=True)  # Make actual request
            #print("Fetched the latest micromamba release successfully.")
            #return  # Success, break out of the loop
        #except requests.exceptions.RequestException as e:
            #print(f"Error fetching latest micromamba release, retrying... {e}")
            #time.sleep(retry_delay)

    #pytest.fail("Failed to fetch the latest micromamba release info after multiple retries.")


#def test_get_all_tags_github_with_invalid_url():
    #"""
    #Test the behavior when the GitHub API endpoint is invalid (to check error handling).
    #"""
    #invalid_url = "https://api.github.com/repos/mamba-org/micromamba-releases/invalid_tags"
    #try:
        ## Temporarily override the URL to simulate failure
        #response = requests.get(invalid_url)
        #response.raise_for_status()  # Will raise HTTPError for bad responses
        #pytest.fail("Expected HTTPError due to invalid URL, but the request succeeded.")
    #except requests.exceptions.RequestException as e:
        #print(f"Handled expected error: {e}")
        #assert str(e).startswith("404")


#def test_get_micromamba_with_invalid_version():
    #"""
    #Test fetching micromamba with an invalid version.
    #This should raise an error or handle the scenario gracefully.
    #"""
    #invalid_version = "999.999.999"  # Invalid version that doesn't exist
    #try:
        #get_micromamba(invalid_version, use_default_version=False)
        #pytest.fail(f"Expected failure for invalid version {invalid_version}, but the request succeeded.")
    #except requests.exceptions.RequestException as e:
        #print(f"Handled expected error: {e}")
        #assert str(e).startswith("404")
