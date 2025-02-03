import base64
import os
from diagrams import Diagram
from diagrams.aws.storage import S3

# Function to get base64 encoded S3 icon
def get_icon_svg(service_type):
    # Hardcode S3 service as example
    if service_type.lower() == "s3":
        icon_path = os.path.join(os.path.dirname(S3.__module__), S3._icon_dir, S3._icon)

        if os.path.exists(icon_path):
            with open(icon_path, "rb") as img_file:
                base64_data = base64.b64encode(img_file.read()).decode('utf-8')
                return f"data:image/png;base64,{base64_data}"
    return None

# Create Diagram
with Diagram("AWS S3 Icon", outformat="svg", filename="aws_s3_diagram"):
    # Use base64 encoded icon for S3
    icon_svg = get_icon_svg("s3")
    if icon_svg:
        S3("S3 Bucket", icon=icon_svg)
    else:
        print("Icon not found.")
