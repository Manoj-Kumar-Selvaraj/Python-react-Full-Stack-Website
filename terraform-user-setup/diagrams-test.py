import os
import json
import importlib
from diagrams import Diagram, Cluster, Edge
import pkgutil
from diagrams.aws import __path__ as aws_package_path
from terraform_to_aws_mapping import terraform_to_aws_service_map  # Import the mapping file
from collections import defaultdict

# Step 1: Load AWS icons dynamically
def load_aws_icons():
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

# Step 2: Load Terraform state
def load_tfstate(filename="tfstate.json"):
    if not os.path.exists(filename):
        raise FileNotFoundError(f"Terraform state file '{filename}' not found.")
    with open(filename, "r") as file:
        return json.load(file)

# Step 3: Extract services and dependencies
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

# Step 4: AWS category mapping for clusters
aws_categories = {
    "compute": ["ec2", "lambda", "batch", "ecs", "eks", "fargate"],
    "storage": ["s3", "ebs", "efs", "fsx", "glacier"],
    "database": ["rds", "dynamodb", "aurora", "redshift", "neptune"],
    "networking": ["vpc", "elb", "route53", "cloudfront", "directconnect"],
    "security": ["iam", "kms", "waf", "guardduty", "shield", "cognito"],
    "monitoring": ["cloudwatch", "xray", "logs", "eventbridge", "sns", "sqs"],
    "analytics": ["athena", "glue", "kinesis", "quicksight", "emr"],
    "machinelearning": ["sagemaker", "rekognition", "comprehend", "forecast"],
    "developer": ["codebuild", "codecommit", "codedeploy", "codepipeline"],
    "iot": ["iot", "greengrass", "freertos", "sitewise"],
    "other": ["cloudtrail", "organizations", "servicecatalog"]
}

def get_category(service_type):
    for category, services in aws_categories.items():
        if any(service in service_type for service in services):
            return category
    return "other"

# Step 5: Get AWS icon
def get_icon(service_type):
    aws_service_name = terraform_to_aws_service_map.get(service_type, None)
    if not aws_service_name:
        return None
    service_name = "".join([part.capitalize() for part in aws_service_name.replace(" ", "").split("_")])
    for module, icons in aws_icons.items():
        if service_name.lower() in icons:
            return icons[service_name.lower()]
    return None

# Step 6: Generate dynamic clusters
def create_diagram(services, dependency_matrix, output_file="output_diagram"):
    nodes = {}
    categories = defaultdict(list)
    
    for service_type, resource_name in services:
        category = get_category(service_type)
        categories[category].append((service_type, resource_name))
    
    with Diagram("AWS Architecture Diagram", show=False, filename=output_file, outformat="png", graph_attr={"size": "20,10"}):
        cluster_nodes = {}
        
        for category, items in categories.items():
            with Cluster(category.capitalize()):
                for service_type, resource_name in items:
                    icon = get_icon(service_type)
                    if icon:
                        cluster_nodes[resource_name] = icon(f"{resource_name}\n({service_type})")
        
        for (source_type, source_name), dependencies in dependency_matrix.items():
            for target_name in dependencies:
                if source_name in cluster_nodes and target_name in cluster_nodes:
                    cluster_nodes[source_name] >> Edge(color="blue", style="dashed", xlabel="Dependency") >> cluster_nodes[target_name]

# Main execution
if __name__ == "__main__":
    try:
        tfstate_data = load_tfstate("tfstate.json")
        services, dependency_matrix = extract_services(tfstate_data)
        create_diagram(services, dependency_matrix)
        print("Diagram generation complete. Check the output file.")
    except Exception as e:
        print(f"Error: {e}")
