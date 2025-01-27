import json
from diagrams import Diagram
from diagrams.generic import _Generic
from importlib import import_module


# Load the Terraform state JSON file
with open("tfstate.json", "r") as file:
    tfstate = json.load(file)


# Function to extract resources from the Terraform state
def extract_resources(state):
    resources = []
    for resource in state.get("resources", []):
        resource_type = resource["type"]
        resource_name = resource["name"]
        resources.append((resource_type, resource_name))
    return resources


# Dynamically map Terraform resource types to Diagrams components
def map_to_diagram(resource_type, resource_name):
    try:
        # Extract the category and specific service (e.g., aws_instance -> compute.EC2)
        category, service = resource_type.split("_", 1)
        module_name = f"diagrams.aws.{category}"
        imported_module = import_module(module_name)

        # Dynamically get the class for the service
        service_class = getattr(imported_module, service.capitalize(), None)

        if service_class:
            return service_class(resource_name)
        else:
            # Use a generic resource if the specific class is not available
            return Generic(resource_name)
    except Exception as e:
        print(f"Error mapping resource {resource_name} of type {resource_type}: {e}")
        return None


# Extract resources from the state
resources = extract_resources(tfstate)

# Generate the architecture diagram
with Diagram("Terraform Architecture Diagram", show=False):
    # Create a dictionary of nodes
    nodes = {r[1]: map_to_diagram(r[0], r[1]) for r in resources if map_to_diagram(r[0], r[1]) is not None}

    # Define relationships (this is an example, you need to adapt based on your architecture)
    for resource_name, node in nodes.items():
        if "instance" in resource_name:  # Example: Connect instances to other resources
            for other_name, other_node in nodes.items():
                if resource_name != other_name:
                    node >> other_node
