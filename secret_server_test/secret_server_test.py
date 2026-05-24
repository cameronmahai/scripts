import requests
import re
import os
import json
import subprocess

def get_credential(file_path, key):
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return None
    with open(file_path, 'r') as f:
        content = f.read()
        match = re.search(f"{key}:\\s*([^\\s\\n]+)", content)
        if match:
            return match.group(1)
    return None

def encrypt_credentials(email, username, password, output_file):
    temp_file = "temp_creds.txt"
    with open(temp_file, "w") as f:
        f.write(f"SFTP Username: {username}\n")
        f.write(f"SFTP Password: {password}\n")
    
    try:
        # --yes to overwrite existing, --encrypt, --recipient
        # --always-trust avoids interactive prompts for untrusted keys
        subprocess.run([
            "gpg", "--yes", "--batch", "--encrypt", 
            "--recipient", email, 
            "--always-trust",
            "--output", output_file, 
            temp_file
        ], check=True, capture_output=True, text=True)
        print(f"\nEncrypted credentials file created: {output_file}")
    except subprocess.CalledProcessError as e:
        print(f"\nError encrypting file: {e.stderr}")
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)

api_credential_file="secretserver_api_credentials.txt"

# 1. Load Credentials from files
api_user = get_credential(api_credential_file, "api_username")
api_pass = get_credential(api_credential_file, "api_password")
sftp_user = get_credential("sftp_credentials.txt", "sftp_username")
sftp_pass = get_credential("sftp_credentials.txt", "sftp_password")

if not all([api_user, api_pass, sftp_user, sftp_pass]):
    print("Error: Could not find all required credentials in the .txt files.")
    exit(1)

# 2. Collect Interactive Input
ticket_num = input("Ticket #: ")
merchant_name = input("Merchant Name: ")
processor = input("Processor: ")
pgp_email = input("PGP email: ")
cpair_user = input("cpair username: ")

secret_name = f"#{ticket_num} {merchant_name} {processor} SFTP Credentials"

# 3. Simulate OAuth Authentication
auth_url = "https://httpbin.org/post"
auth_data = {
    "username": api_user,
    "password": api_pass,
    "grant_type": "password"
}

response_1 = requests.post(auth_url, data=auth_data).json()
token = response_1.get("form", {}).get("username", "MOCK_TOKEN_12345")

# 4. Simulate Creating the Secret
secret_url = "https://httpbin.org/post"
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
payload = {
    "secretTemplateId": 6000,
    "folderId": 1,
    "items": [
        {"fieldName": "Secret Name", "value": secret_name},
        {"fieldName": "Username", "value": sftp_user},
        {"fieldName": "Password", "value": sftp_pass},
        {"fieldName": "Notes", "value": f"sftp -P 22 {sftp_user}@vault-migrations.api-production.braintree.com"}
    ]
}

response_2 = requests.post(secret_url, json=payload, headers=headers)

# Prettified output
print(f"\nSecret created in Secret Server: {secret_name}")
print("\nResponse from Server:")
print(json.dumps(response_2.json(), indent=4))

# 5. Encrypt SFTP credentials for delivery
clean_merchant = merchant_name.replace(" ", "_")
clean_processor = processor.replace(" ", "_")
output_filename = f"{clean_merchant}_{clean_processor}_SFTP_creds.txt.gpg"

encrypt_credentials(pgp_email, sftp_user, sftp_pass, output_filename)
