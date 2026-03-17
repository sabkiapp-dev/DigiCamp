from paramiko import SSHClient, AutoAddPolicy
import zipfile
import os
from getpass import getpass
from scp import SCPClient
import shutil


# get current directory
current_dir = os.path.dirname(os.path.abspath(__file__))

# join directory with file name
web_dir_path = os.path.join(current_dir, "build", "web")
calls_dir_path = os.path.join(current_dir, "build", "call")
calls_zip_path = os.path.join(current_dir, "build", "call.zip")

print(f"Web dir path: {web_dir_path}")
print(f"Calls dir path: {calls_dir_path}")
print(f"Calls zip path: {calls_zip_path}")


# Delete the existing web directory
if os.path.exists(web_dir_path):
    print("Deleting the existing web directory...")
    shutil.rmtree(web_dir_path)

# Delete the existing call directory
if os.path.exists(calls_dir_path):
    print("Deleting the existing call directory...")
    shutil.rmtree(calls_dir_path)

# Delete the existing call.zip file
if os.path.exists(calls_zip_path):
    print("Deleting the existing call.zip file...")
    shutil.rmtree(calls_zip_path)


print("Building the web app...")
os.system(f"flutter build web")

# rename the web directory to call
shutil.move(web_dir_path, calls_dir_path)

# Copy the .htaccess file from the current directory to the call directory
htaccess_path = os.path.join(current_dir, ".htaccess")
shutil.copy(htaccess_path, calls_dir_path)

# i want to modify a file called index.html which have a tag <base href="/"> rename this to <base href="./"> in the call folder
# index_html_path = os.path.join(calls_dir_path, "index.html")
# with open(index_html_path, "r") as file:
#     data = file.read()
#     data = data.replace('<base href="/">', '<base href="./">')
#     with open(index_html_path, "w") as file:
#         file.write(data)

# Zip the call folder
print("Zipping the call folder...")
with zipfile.ZipFile(calls_zip_path, 'w') as zipf:
    for root, _, files in os.walk(calls_dir_path):
        for file in files:
            file_path = os.path.join(root, file)
            arcname = os.path.relpath(file_path, calls_dir_path)
            zipf.write(file_path, arcname=arcname)

# Prompt the user for the password
password = getpass("Enter the password: ")

# Upload the zip file using scp
print("Uploading the zip file using scp...")

ssh = SSHClient()
ssh.load_system_host_keys()
ssh.set_missing_host_key_policy(AutoAddPolicy())
ssh.connect('sabkiapp.com', 22, 'root', password)

# remove the previous call.zip file and call folder
print("Removing the previous call.zip and call folder...")
ssh.exec_command('rm -rf /var/www/call.zip')
ssh.exec_command('rm -rf /var/www/call')


def progress(filename, size, sent):
    print(f"Uploading {filename}... {sent/size*100:.2f}%")


print("Uploading the call.zip file...")
# Show progress
with SCPClient(ssh.get_transport(), progress=progress) as scp:
    scp.put(calls_zip_path, '/var/www/')
    print("Upload successful!")

print("Extracting the call.zip file...")
ssh.exec_command('unzip -o /var/www/call.zip -d /var/www/call/')
print("Extraction successful!")

print("Removing the call.zip file...")
ssh.exec_command('rm -rf /var/www/call.zip')
print("Removal successful!")


ssh.close()
print("Deployment successful!")
