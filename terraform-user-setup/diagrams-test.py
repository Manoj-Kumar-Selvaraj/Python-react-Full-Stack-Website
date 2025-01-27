import requests
import json
import os
from PIL import Image, ImageDraw
import cairosvg

# Folder to store AWS icons locally
icons_folder = "aws_icons"
if not os.path.exists(icons_folder):
    os.makedirs(icons_folder)

# Function to generate AWS service icon name based on naming conventions
def get_service_icon_name(resource_name):
    # Remove the 'aws_' prefix and make the first letter of each word capitalized
    service_name_parts = resource_name.replace('aws_', '').split('_')
    service_icon_name = ''.join([part.capitalize() for part in service_name_parts])
    return service_icon_name

# Function to fetch AWS service icon from https://awsicons.dev and save locally
def fetch_icon(service_name):
    # Generate service icon name using the naming convention
    service_icon_name = get_service_icon_name(service_name)

    # URL to AWS Icons website (using the dynamic service name for the icon)
    icon_url = f"https://awsicons.dev/icons/{service_icon_name}.svg"

    # Local file path for the SVG and PNG
    svg_icon_path = os.path.join(icons_folder, f"{service_icon_name}.svg")
    png_icon_path = os.path.join(icons_folder, f"{service_icon_name}.png")

    if not os.path.exists(svg_icon_path):
        try:
            # Fetch icon from the AWS Icons website
            response = requests.get(icon_url)
            if response.status_code == 200:
                # Save the SVG locally
                with open(svg_icon_path, 'wb') as file:
                    file.write(response.content)
                print(f"Downloaded {service_icon_name} icon (SVG).")
            else:
                print(f"Failed to download icon for {service_icon_name}. HTTP status {response.status_code}")
        except Exception as e:
            print(f"Error fetching icon for {service_icon_name}: {e}")

    # Convert SVG to PNG if not already converted
    if not os.path.exists(png_icon_path):
        try:
            # Attempt to convert the SVG to PNG
            cairosvg.svg2png(url=svg_icon_path, write_to=png_icon_path)
            print(f"Converted {service_icon_name} icon to PNG.")
        except Exception as e:
            print(f"Error converting {service_icon_name} icon to PNG: {e}")

    return png_icon_path

# Load tfstate.json file
def load_tfstate(filename="tfstate.json"):
    with open(filename, 'r') as file:
        return json.load(file)

# Recursive function to extract services and resource names from nested modules
def extract_services(json_data):
    services = []

    def extract_from_module(module):
        if 'resources' in module:
            for resource in module['resources']:
                service_name = resource.get('type', '')
                resource_name = resource.get('name', '')
                if service_name.startswith('aws_'):  # Only consider AWS resources
                    services.append((service_name, resource_name))

        # Check if the module has child modules and recursively extract from them
        if 'child_modules' in module:
            for child_module in module['child_modules']:
                extract_from_module(child_module)

    # Extract services from the root module
    root_module = json_data.get('values', {}).get('root_module', {})
    extract_from_module(root_module)

    return services

# Create the image with AWS service icons, service names, and resource names
def create_image(services):
    img_width, img_height = 800, 1000
    img = Image.new('RGB', (img_width, img_height), color='white')
    draw = ImageDraw.Draw(img)
    
    y_offset = 20
    icon_size = 50  # Size of the icons
    
    for service, resource in services:
        # Fetch or download the icon based on the service name
        icon_path = fetch_icon(service)

        if os.path.exists(icon_path):
            try:
                icon = Image.open(icon_path).resize((icon_size, icon_size))
                img.paste(icon, (20, y_offset))  # Paste the icon on the image at the given position
            except Exception as e:
                print(f"Error loading icon for {service}: {e}")
        else:
            draw.text((20, y_offset), "Icon not found", fill='black')

        # Draw the service name and resource name
        draw.text((80, y_offset), service, fill='black')  # Draw service name
        y_offset += icon_size + 10
        draw.text((80, y_offset), resource, fill='gray')  # Draw resource name
        
        # Increase the y_offset to space out resources
        y_offset += 40
    
    # Save or show the image
    img.save("aws_services_image.png")
    img.show()

# Load the tfstate data
tfstate_data = load_tfstate()

# Extract the services and resources
services = extract_services(tfstate_data)

# Create and display the image
create_image(services)
