import os
import json
import importlib
from diagrams import Diagram, Edge
import pkgutil
from diagrams.aws import __path__ as aws_package_path
from terraform_to_aws_mapping import terraform_to_aws_service_map  # Import the mapping file
import re
from collections import defaultdict

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
    dependency_matrix = {}

    def parse_module(module):
        for i in range(len(module)):
            resource = module[i]
            service_type = resource.get("type", "")
            resource_name = resource.get("name", "")
            if service_type.startswith("aws_"):
                services.append((service_type, resource_name))
                dependency_matrix[(service_type, resource_name)]=[]
            try:
                for dependency in resource["instances"][0]["dependencies"]:
                    pattern = r'([^\.]+)$'
                    dependency_name = re.search(pattern, dependency).group(1)
                    dependency_matrix[(service_type, resource_name)].append(dependency_name)
            except KeyError:
                print(f"No Dependencies for {resource_name} ") 
                dependency_matrix[(service_type, resource_name)] = []   
    root_module = json_data.get("resources", {})
    print(f"Parsing root module...")  # Debugging: print parsing start message
    l = len(root_module)
    print(l)
    # print(root_module.type)
    parse_module(root_module)
    print(f"Extracted {len(services)} services.")  # Debugging: print how many services were extracted
    updated_dependency_matrix = defaultdict(list)
    for (service_type,resource_name) in services:
        print(f"service_type:{service_type}")
        if (service_type, resource_name) in dependency_matrix.keys():
            print(f"Resource:{resource_name}")
            for dependency_name in dependency_matrix[(service_type, resource_name)]:
                # Find service type of dependency
                for dep_service_type, dep_resource_name in services:
                    if dep_resource_name == dependency_name:
                        updated_dependency_matrix[(service_type, resource_name)].append((dep_service_type, dependency_name))

    # Print result
    for key, value in updated_dependency_matrix.items():
        print(f"{key}: {value}")

    return services, updated_dependency_matrix

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
def create_diagram(services, dependency_matrix, output_file="output_diagram"):
    """Generate an AWS architecture diagram using the extracted services."""
    nodes = {}
    print(f"Generating diagram...")  # Debugging: print diagram generation start
    with Diagram("AWS Architecture Diagram", show=False, filename=output_file):
        for service_type, resource_name in services:
            icon = get_icon(service_type)
            if icon:
                print(f"Adding icon for {resource_name}")  # Debugging: print adding icon
                nodes[resource_name] = icon(resource_name)
            else:
                print(f"Icon not found for {service_type} ({resource_name})")  # Debugging: print missing icon
        
        # Add edges for dependencies

        for (source_type, source_name), dependencies in dependency_matrix.items():
            for (target_type, target_name) in dependencies:
                if source_name in nodes and target_name in nodes:
                    print(f"Adding edge from {source_name} to {target_name}")  # Debugging: print adding edge
                    nodes[source_name] >> Edge(color="blue") >> nodes[target_name]


# Main execution
if __name__ == "__main__":
    try:
        # Load Terraform state file
        tfstate_data = load_tfstate("tfstate.json")

        # Extract AWS services from the state file
        services, dependency_matrix = extract_services(tfstate_data)

        # Generate the diagram with the extracted services
        create_diagram(services, dependency_matrix)
        print("Diagram generation complete. Check the output file.")
    except Exception as e:
        print(f"Error: {e}")