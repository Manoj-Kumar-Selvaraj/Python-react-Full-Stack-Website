import base64
import os
import sys
from diagrams import Diagram
from diagrams.aws.storage import S3

# Get the base directory of the diagrams package dynamically
diagrams_package_path = os.path.join(sys.prefix, 'lib', 'python3.12', 'site-packages', 'resources', 'aws')

print(f"Diagrams package location: {diagrams_package_path}")

# Check if S3 icon exists under this path
icon_dir = os.path.join(diagrams_package_path, 'storage')
s3_icon_path = os.path.join(icon_dir, 'simple-storage-service-s3.png')
print(f"S3 icon path: {s3_icon_path}")

# Function to get base64 encoded icon
def get_icon_svg(icon_path):
    if os.path.exists(icon_path):
        with open(icon_path, "rb") as img_file:
            base64_data = base64.b64encode(img_file.read()).decode('utf-8')
            return f"data:image/png;base64,{base64_data}"
    return None

# Create the Diagram
with Diagram("AWS S3 Icon", outformat="svg", filename="aws_s3_diagram"):
    # Use base64 encoded icon for S3
    icon_svg = get_icon_svg(s3_icon_path)
    
    if icon_svg:
        # Set the base64 encoded image as the icon for S3
        S3("S3 Bucket", icon=icon_svg)
    else:
        print("Icon not found.")
