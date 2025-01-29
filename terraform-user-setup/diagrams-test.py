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
    for module_name in aws_modules:
        try:
            module = importlib.import_module(f"diagrams.aws.{module_name}")
            icons = {icon.lower(): getattr(module, icon) for icon in dir(module) if not icon.startswith("_")}
            aws_icons[module_name.lower()] = icons
        except ImportError:
            continue
    return aws_icons

aws_icons = load_aws_icons()

# Step 2: Load and parse Terraform state file
def load_tfstate(filename="tfstate.json"):
    """Load the Terraform state file."""
    if not os.path.exists(filename):
        raise FileNotFoundError(f"Terraform state file '{filename}' not found.")
    with open(filename, "r") as file:
        return json.load(file)

# Step 3: Extract services and dependencies
def extract_services(json_data):
    """Extract AWS services and only immediate dependencies from Terraform state."""
    services = []
    dependency_matrix = defaultdict(set)

    for resource in json_data.get("resources", []):
        service_type = resource.get("type", "")
        resource_name = resource.get("name", "")
        if service_type.startswith("aws_"):
            services.append((service_type, resource_name))
            dependencies = resource.get("instances", [{}])[0].get("dependencies", [])
            direct_dependencies = {dep.split(".")[-1] for dep in dependencies if dep.split(".")[-1] != resource_name}
            dependency_matrix[(service_type, resource_name)] = direct_dependencies
    
    # Filter out indirect dependencies
    filtered_dependency_matrix = defaultdict(set)
    for (service_type, resource_name), dependencies in dependency_matrix.items():
        direct_deps = set()
        for dependency_name in dependencies:
            if any(dep_name == dependency_name for _, dep_name in services):
                direct_deps.add(dependency_name)
        filtered_dependency_matrix[(service_type, resource_name)] = direct_deps
    
    return services, filtered_dependency_matrix

# Step 4: Map resources to AWS icons
def get_icon(service_type):
    """Fetch the corresponding AWS icon based on the service type."""
    aws_service_name = terraform_to_aws_service_map.get(service_type, None)
    if not aws_service_name:
        return None
    service_name = "".join([part.capitalize() for part in aws_service_name.replace(" ", "").split("_")])
    for module, icons in aws_icons.items():
        if service_name.lower() in icons:
            return icons[service_name.lower()]
    return None

# Step 5: Generate diagram
def create_diagram(services, dependency_matrix, output_file="output_diagram"):
    """Generate an AWS architecture diagram using the extracted services."""
    nodes = {}
    with Diagram("AWS Architecture Diagram", show=False, filename=output_file):
        for service_type, resource_name in services:
            icon = get_icon(service_type)
            if icon:
                nodes[resource_name] = icon(resource_name, width="2.0", height="2.0")  # Increased icon size
        
        for (source_type, source_name), dependencies in dependency_matrix.items():
            for target_name in dependencies:
                if source_name in nodes and target_name in nodes:
                    nodes[target_name] >> Edge(color="blue") >> nodes[source_name]  # Reversed arrow direction

# Main execution
if __name__ == "__main__":
    try:
        tfstate_data = load_tfstate("tfstate.json")
        services, dependency_matrix = extract_services(tfstate_data)
        create_diagram(services, dependency_matrix)
        print("Diagram generation complete. Check the output file.")
    except Exception as e:
        print(f"Error: {e}")
