import os
import json
import importlib
from diagrams import Diagram
import pkgutil
from diagrams.aws import __path__ as aws_package_path
from terraform_to_aws_mapping import terraform_to_aws_service_map  # Import the mapping file

# Step 1: Dynamically import AWS icons
def load_aws_icons():
    """Dynamically load AWS icons from diagrams.aws."""
    aws_icons = {}
    aws_modules = [name for _, name, _ in pkgutil.iter_modules(aws_package_path)]
    print(f"Found AWS modules: {aws_modules}")  # Debugging: print the AWS modules found
    for module_name in aws_modules:
        try:
            print(f"Attempting to import diagrams.aws.{module_name}...")  # Debugging: module import
            module = importlib.import_module(f"diagrams.aws.{module_name}")
            icons = {icon.lower(): getattr(module, icon) for icon in dir(module) if not icon.startswith("_")}
            aws_icons[module_name.lower()] = icons
            print(f"Successfully imported {module_name} with {len(icons)} icons.")  # Debugging: print imported icons count
        except ImportError as e:
            print(f"Failed to import diagrams.aws.{module_name}: {e}")  # Debugging: import failure message
            continue
    return aws_icons

aws_icons = load_aws_icons()

# Step 2: Load and parse Terraform state file
def load_tfstate(filename="tfstate.json"):
    """Load the Terraform state file."""
    if not os.path.exists(filename):
        raise FileNotFoundError(f"Terraform state file '{filename}' not found.")
    with open(filename, "r") as file:
        print(f"Loading Terraform state file: {filename}")  # Debugging: print the loading message
        return json.load(file)

def extract_services(json_data):
    """Recursively extract AWS services and resource names from Terraform state."""
    services = []

    def parse_module(module):
        if "resources" in module:
            for resource in module["resources"]:
                service_type = resource.get("type", "")
                resource_name = resource.get("name", "")
                if service_type.startswith("aws_"):
                    services.append((service_type, resource_name))
        if "child_modules" in module:
            for child in module["child_modules"]:
                parse_module(child)

    root_module = json_data.get("values", {}).get("root_module", {})
    print(f"Parsing root module...")  # Debugging: print parsing start message
    parse_module(root_module)
    print(f"Extracted {len(services)} services.")  # Debugging: print how many services were extracted
    return services

# Step 3: Map resources to AWS icons
def get_icon(service_type):
    """Fetch the corresponding AWS icon based on the service type."""
    # Use the terraform_to_aws mapping to find the AWS service name
    aws_service_name = terraform_to_aws_service_map.get(service_type, None)
    
    if not aws_service_name:
        print(f"No AWS service mapping found for {service_type}")  # Debugging: No mapping found
        return None
    
    # Try to format the AWS service name to match icon names
    service_parts = aws_service_name.replace(" ", "").split("_")
    service_name = "".join([part.capitalize() for part in service_parts])
    print(f"Searching for icon for service type: {service_type} ({service_name})")  # Debugging: print service being searched
    for module, icons in aws_icons.items():
        if service_name.lower() in icons:
            return icons[service_name.lower()]
    
    print(f"Icon not found for {service_type}")  # Debugging: print icon not found message
    return None  # Return None if no matching icon is found

# Step 4: Generate diagram
def create_diagram(services, output_file="output_diagram"):
    """Generate an AWS architecture diagram using the extracted services."""
    print(f"Generating diagram...")  # Debugging: print diagram generation start
    with Diagram("AWS Architecture Diagram", show=False, filename=output_file):
        for service_type, resource_name in services:
            icon = get_icon(service_type)
            if icon:
                print(f"Adding icon for {resource_name}")  # Debugging: print adding icon
                icon(resource_name)
            else:
                print(f"Icon not found for {service_type} ({resource_name})")  # Debugging: print missing icon

# Main execution
if __name__ == "__main__":
    try:
        # Load Terraform state file
        tfstate_data = load_tfstate("tfstate.json")

        # Extract AWS services from the state file
        services = extract_services(tfstate_data)

        # Generate the diagram with the extracted services
        create_diagram(services)
        print("Diagram generation complete. Check the output file.")
    except Exception as e:
        print(f"Error: {e}")
