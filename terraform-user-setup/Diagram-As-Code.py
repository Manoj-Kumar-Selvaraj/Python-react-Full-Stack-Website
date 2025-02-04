import os
import json
import importlib
import logging
import traceback
import pkgutil
import re
from diagrams.custom import Custom
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
            "nodesep": "0.5",  
            "ranksep": "0.6"  
        }
        
        with Diagram("AWS Architecture Diagram", show=False, filename=output_file, outformat="svg", graph_attr=graph_attrs):
            cluster_nodes = {}

            for category, items in categories.items():
                with Cluster(category):
                    for service_type, resource_name in items:
                        icon = get_icon(service_type)
                        if icon:
                            # Hide label, add JavaScript tooltip
                            icon = icon("", href=f"javascript:showTooltip(event, '{resource_name}', '{service_type}')",
                                        shape="box", width="0.5", height="0.4")
                            cluster_nodes[resource_name] = icon

            # Add dependencies
            for (source_type, source_name), dependencies in dependency_matrix.items():
                if source_name in cluster_nodes:
                    targets = [cluster_nodes[target_name] for target_name in dependencies if target_name in cluster_nodes]
                    if targets:
                        cluster_nodes[source_name] >> Edge(color="black", penwidth="1") >> targets

        # Read generated SVG and inject JavaScript
        with open(output_file + ".svg", "r") as file:
            svg_content = file.read()

        tooltip_js = """
<script><![CDATA[
function showTooltip(evt, resourceName, serviceType) {
    let tooltip = document.getElementById("tooltip");
    tooltip.innerHTML = `<b>Resource:</b> ${resourceName}<br/><b>Type:</b> ${serviceType}`;
    tooltip.style.left = evt.pageX + "px";
    tooltip.style.top = evt.pageY + "px";
    tooltip.style.display = "block";
}

document.addEventListener("click", function(event) {
    let tooltip = document.getElementById("tooltip");
    if (!event.target.closest("[href^='javascript:showTooltip']")) {
        tooltip.style.display = "none";
    }
});
]]></script>

<style><![CDATA[
#tooltip {
    display: none;
    position: absolute;
    background: white;
    border: 1px solid black;
    padding: 8px;
    border-radius: 5px;
    box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.2);
    font-size: 14px;
}
]]></style>

<div id="tooltip"></div>
"""

        updated_svg_content = svg_content.replace("</svg>", tooltip_js + "\n</svg>")

        with open("infrastructure_architecture.svg", "w") as file:
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
