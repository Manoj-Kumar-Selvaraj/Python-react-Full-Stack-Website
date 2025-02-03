import os
import json
import importlib
import logging
import traceback
import pkgutil
import re
from diagrams import Diagram, Cluster, Edge
from diagrams.aws import __path__ as aws_package_path
from terraform_to_aws_mapping import terraform_to_aws_service_map  
from collections import defaultdict

# Configure logging
logging.basicConfig(
    filename="error_log.txt", 
    level=logging.ERROR, 
    format="%(asctime)s - %(levelname)s - %(message)s"
)

# Adjustable icon size
ICON_SIZE = "20"  # Adjust for better visibility

# Load AWS icons dynamically
def load_aws_icons():
    aws_icons = {}
    aws_modules = [name for _, name, _ in pkgutil.iter_modules(aws_package_path)]
    for module_name in aws_modules:
        try:
            module = importlib.import_module(f"diagrams.aws.{module_name}")
            icons = {icon.lower(): getattr(module, icon) for icon in dir(module) if not icon.startswith("_")}
            aws_icons[module_name.lower()] = icons
        except ImportError as e:
            logging.error(f"Failed to import AWS module {module_name}: {e}")
            continue
    return aws_icons

aws_icons = load_aws_icons()

# Load Terraform state
def load_tfstate(filename="tfstate.json"):
    if not os.path.exists(filename):
        error_message = f"Terraform state file '{filename}' not found."
        logging.error(error_message)
        raise FileNotFoundError(error_message)
    with open(filename, "r") as file:
        return json.load(file)

# Extract services and dependencies
def extract_services(json_data):
    services = []
    dependency_matrix = defaultdict(set)

    for resource in json_data.get("resources", []):
        service_type = resource.get("type", "")
        resource_name = resource.get("name", "")
        if service_type.startswith("aws_"):
            services.append((service_type, resource_name))
            dependencies = resource.get("instances", [{}])[0].get("dependencies", [])
            dependency_matrix[(service_type, resource_name)].update(
                {dep.split(".")[-1] for dep in dependencies if dep.split(".")[-1] != resource_name}
            )
    return services, dependency_matrix

# AWS category mapping for clusters
aws_categories = {
    "Compute": ["ec2", "lambda", "batch", "ecs", "eks", "fargate"],
    "Storage": ["s3", "ebs", "efs", "fsx", "glacier"],
    "Database": ["rds", "dynamodb", "aurora", "redshift", "neptune"],
    "Networking": ["vpc", "elb", "route53", "cloudfront", "directconnect"],
    "Security": ["iam", "kms", "waf", "guardduty", "shield", "cognito"],
    "Monitoring": ["cloudwatch", "xray", "logs", "eventbridge", "sns", "sqs", "cloudtrail"],
    "Analytics": ["athena", "glue", "kinesis", "quicksight", "emr"],
    "Machine Learning": ["sagemaker", "rekognition", "comprehend", "forecast"],
    "Developer": ["codebuild", "codecommit", "codedeploy", "codepipeline"],
    "IoT": ["iot", "greengrass", "freertos", "sitewise"],
    "Other": ["organizations", "servicecatalog"]
}

def get_category(service_type):
    for category, services in aws_categories.items():
        if any(service in service_type for service in services):
            return category
    return "Other"

# Get AWS icon
def get_icon(service_type):
    aws_service_name = terraform_to_aws_service_map.get(service_type, None)
    if not aws_service_name:
        return None
    service_name = "".join([part.capitalize() for part in aws_service_name.replace(" ", "").split("_")])
    for module, icons in aws_icons.items():
        if service_name.lower() in icons:
            return icons[service_name.lower()]
    return None

# Generate diagram with better spacing and alignment
def create_diagram(services, dependency_matrix, output_file="output_diagram"):
    try:
        nodes = {}
        categories = defaultdict(set)
        
        for service_type, resource_name in services:
            category = get_category(service_type)
            categories[category].add((service_type, resource_name))
        
        graph_attrs = {
            "size": "300,200", 
            "dpi": "200",
            "rankdir": "TB",  # Top to Bottom layout
            "nodesep": "0.5",  # Slightly increased spacing between nodes
            "ranksep": "0.6"  # Slightly increased spacing between ranks
        }
        
        edge_attrs = {
            "penwidth": "0.5",  # Thin edges
            "color": "blue",
            "arrowsize": "0.6",  # Moderate arrow size
            "fontcolor": "black"
        }
        
        with Diagram("AWS Architecture Diagram", show=False, filename=output_file, outformat="svg", graph_attr=graph_attrs, edge_attr=edge_attrs):
            cluster_nodes = {}

            for category, items in categories.items():
                with Cluster(category):
                    sub_nodes = []
                    for service_type, resource_name in items:
                        icon = get_icon(service_type)
                        if icon:
                            node = icon(f"\n[{resource_name}]", fontsize=ICON_SIZE, shape="box", width="0.5", height="0.4", tooltip=f"{resource_name} ({service_type})")
                            sub_nodes.append(node)
                    cluster_nodes.update({item[1]: sub_nodes[i] for i, item in enumerate(items)})

            # Reverse arrows and improve dependencies
            for (source_type, source_name), dependencies in dependency_matrix.items():
                if source_name in cluster_nodes:
                    targets = [cluster_nodes[target_name] for target_name in dependencies if target_name in cluster_nodes]
                    if targets:
                        cluster_nodes[source_name] << Edge(
                            xlabel="Uses", color="black", fontcolor="black", style="bold", penwidth="1", tooltip="Dependency"
                        ) << targets

        # After diagram creation, update local paths with S3 URLs using re
        with open(output_file + ".svg", "r") as file:
            svg_content = file.read()

        base_url = "https://factoryoutlet-aws-diagrams-resources.s3.us-east-1.amazonaws.com/resources/"
        pattern = r'(<image[^>]+xlink:href=")(/home/codespace/.python[^"]+)(")'
        updated_svg_content = re.sub(pattern, lambda match: match.group(1) + base_url + match.group(2).split('/resources/')[-1] + match.group(3), svg_content)

        with open("infrastructure_architecture" + ".svg", "w") as file:
            file.write(updated_svg_content)

    except Exception as e:
        logging.error(f"Error generating diagram: {e}")
        logging.error(traceback.format_exc())
        raise

# Main execution
if __name__ == "__main__":
    try:
        tfstate_data = load_tfstate("tfstate.json")
        services, dependency_matrix = extract_services(tfstate_data)
        create_diagram(services, dependency_matrix)
    except Exception as e:
        logging.error(f"Unhandled exception: {e}")
        logging.error(traceback.format_exc())
