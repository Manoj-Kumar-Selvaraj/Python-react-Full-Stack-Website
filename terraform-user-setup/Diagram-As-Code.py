import os
import json
import importlib
import logging
import traceback
import pkgutil
import re
import openai
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

ICON_SIZE = "20"



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

def load_tfstate(filename="tfstate.json"):
    if not os.path.exists(filename):
        error_message = f"Terraform state file '{filename}' not found."
        logging.error(error_message)
        raise FileNotFoundError(error_message)
    with open(filename, "r") as file:
        return json.load(file)

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

def get_icon(service_type):
    aws_service_name = terraform_to_aws_service_map.get(service_type, None)
    if not aws_service_name:
        return None
    service_name = "".join([part.capitalize() for part in aws_service_name.replace(" ", "").split("_")])
    for module, icons in aws_icons.items():
        if service_name.lower() in icons:
            return icons[service_name.lower()]
    return None

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
            "rankdir": "TB",
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
                            icon = icon(f"{resource_name}\n{service_type}",
                                        shape="box", width="0.5", height="0.4")
                            cluster_nodes[resource_name] = icon

            for (source_type, source_name), dependencies in dependency_matrix.items():
                if source_name in cluster_nodes:
                    targets = [cluster_nodes[target_name] for target_name in dependencies if target_name in cluster_nodes]
                    if targets:
                        cluster_nodes[source_name] >> Edge(color="black", penwidth="1") >> targets

        with open(output_file + ".svg", "r") as file:
            svg_content = file.read()

        base_url = "https://factoryoutlet-aws-diagrams-resources.s3.us-east-1.amazonaws.com/resources/"
        pattern = r'(<image[^>]+xlink:href=")(/home/codespace/.python[^"]+)(")'
        updated_svg_content = re.sub(pattern, lambda match: match.group(1) + base_url + match.group(2).split('/resources/')[-1] + match.group(3), svg_content)

        with open("infrastructure_architecture.svg", "w") as file:
            file.write(updated_svg_content)

    except Exception as e:
        logging.error(f"Error generating diagram: {e}")
        logging.error(traceback.format_exc())
        raise

def add_interactive_features(svg_file):
    try:
        with open(svg_file, "r") as file:
            svg_content = file.read()

        tool_tip_pattern = re.compile(
            r'(<image[^>]*>)\s*(<text[^>]*?>.*?</text>)\s*(<text[^>]*?>.*?</text>)'
        )

        def add_tooltip(match):
            image_tag, text1, text2 = match.groups()
            text1_content = re.sub(r'<[^>]+>', '', text1).strip()
            text2_content = re.sub(r'<[^>]+>', '', text2).strip()
            tooltip_text = f"""
            <tspan x='0' dy='1.2em' font-weight='bold' fill='#2d3436'>Name: {text1_content}</tspan>
            <tspan x='0' dy='1.2em' font-weight='bold' fill='#636e72'>Service: {text2_content}</tspan>
            """
            tooltip_tag = f'<text x="0" y="0" font-family="Sans-Serif" font-size="12" fill="black" visibility="hidden">{tooltip_text}</text>'

            return f"{image_tag}\n{tooltip_tag}"

        modified_svg_1 = tool_tip_pattern.sub(add_tooltip, svg_content)

        def add_edge_event_attributes(svg_content):
            svg_content = re.sub(
                r'(<path[^>]*?.)(/)>',  
                r'\1 onmouseover="highlightEdge(true, this.parentNode)" '
                r'onmouseout="highlightEdge(false, this.parentNode)" '
                r'onclick="toggleEdge(this.parentNode)"/>',
                svg_content
            )
            svg_content = re.sub(
                r'(<polygon[^>]*?.)(/)>',  
                r'\1 onmouseover="highlightEdge(true, this.parentNode)" '
                r'onmouseout="highlightEdge(false, this.parentNode)" '
                r'onclick="toggleEdge(this.parentNode)"/>',
                svg_content
            )
            return svg_content

        modified_svg = add_edge_event_attributes(modified_svg_1)
        
        additional_scripts = """
            <!-- Clickable Area -->
            <line id="clickable" x1="75" y1="75" x2="325" y2="75" class="clickable-area"
                onmouseover="highlightEdge(true, this)" onmouseout="highlightEdge(false, this)" onclick="toggleEdge(this)"/>

            <script>
                let isActive = false;
                let isHovered = false;

                function highlightEdge(isHovering, element) {
                    isHovered = isHovering;
                    element.classList.toggle("hover", isHovered);
                    console.log("Hover Event:", isHovered, "Element:", element);
                }

                function toggleEdge(element) {
                    isActive = !isActive;
                    element.classList.toggle("active", isActive);
                    console.log("Toggle Edge Active:", isActive, "Element:", element);
                }

                window.addEventListener('resize', handleZoom);
                window.addEventListener('wheel', handleZoom);

                function handleZoom(event) {
                    if (event.ctrlKey || event.metaKey || event.scale !== 1) return;
                }

                function resetEdgeState() {
                    let edges = document.getElementsByClassName("edge");
                    let clickable = document.getElementById("clickable");
                    isActive = false;
                    isHovered = false;

                    for (let edge of edges) {
                        edge.classList.remove("active", "hover");
                    }

                    if (clickable) clickable.setAttribute("stroke", "transparent");
                }

                document.addEventListener('click', (event) => {
                    let edges = document.getElementsByClassName("edge");
                    let isInside = Array.from(edges).some(edge => edge.contains(event.target));
                    if (!isInside) resetEdgeState();
                });
            </script>

            <style>
                .edge.hover path,
                .edge.hover polygon,
                .line.hover {
                    stroke: blue !important;  /* Apply hover color */
                    fill: none !important;
                    stroke-width: 4px; /* Define stroke width */
                    stroke-linecap: round; /* Rounded stroke ends */
                }

                .edge.active path,
                .edge.active polygon,
                .line.active {
                    stroke: green !important;  /* Apply active color */
                    fill: none !important;
                    stroke-width: 4px; /* Define stroke width */
                    stroke-linecap: round; /* Rounded stroke ends */
                }

                text {
                    visibility: hidden;
                    font-size: 12px;
                    fill: black;
                }

                image:hover + text {
                    visibility: visible;
                }

            </style>
        """

        modified_svg = modified_svg.replace("</svg>", f"{additional_scripts}\n</svg>")

        output_file = svg_file.replace(".svg", "_aws.svg")
        with open(output_file, "w") as file:
            file.write(modified_svg)
        

    except Exception as e:
        logging.error(f"Error adding tooltips: {e}")
        logging.error(traceback.format_exc())
        raise

if __name__ == "__main__":
    try:
        tfstate_data = load_tfstate("tfstate.json")
        services, dependency_matrix = extract_services(tfstate_data)
        create_diagram(services, dependency_matrix)
        add_interactive_features("infrastructure_architecture.svg")
    except Exception as e:
        logging.error(f"Unhandled exception: {e}")
        logging.error(traceback.format_exc())
