import sys
sys.path.append("..")
import os
import getpass
import logging
from ruamel.yaml import YAML
from datetime import datetime
from lib.helpers import scan_automation
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def get_ssm_parameter(name):
    ssm_client = boto3.client('ssm')
    try:
        response = ssm_client.get_parameter(Name=name, WithDecryption=True)
        return response['Parameter']['Value']
    except ssm_client.exceptions.ParameterNotFound:
        logging.error(f"Parameter {name} not found")
        raise
    except (NoCredentialsError, PartialCredentialsError) as e:
        logging.error(f"AWS credentials not found or incomplete: {e}")
        raise
    except Exception as e:
        logging.error(f"Error retrieving parameter {name}: {e}")
        raise

def main():
    # Load configuration file
    yaml = YAML(typ='safe')
    settings = yaml.load(open("../config/settings.yml"))
    
    # Setup basic logging
    logging.basicConfig(filename="../log/scan_automation.log", filemode="a", level=logging.INFO,
                        format=str(datetime.now()) + " - %(levelname)s - %(message)s")

    # Get connection info
    if settings.get("connection"):
        api_key = get_ssm_parameter("/ohana-api/appspec-insights/api-key")
        region = settings.get("connection").get("region", "us")
    else:
        api_key = None
        region = "us"

    logging.info(f"Region: {region}")
    scan_automation.create_scan(api_key, region, settings)

if __name__ == "__main__":
    main()