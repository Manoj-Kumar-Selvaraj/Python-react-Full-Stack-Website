import json
import networkx as nx
import matplotlib.pyplot as plt

def add_resource_node(graph, resource):
    # Check if 'type' and 'name' keys exist
    if 'type' in resource and 'name' in resource:
        node_label = f"{resource['type']}\n{resource['name']}"
    else:
        # Handle the case where 'type' or 'name' is missing
        print(f"Resource missing 'type' or 'name': {resource}")
        node_label = "Unknown Resource"
    
    # Add the resource to the graph
    graph.add_node(node_label)
    print(f"Adding node: {node_label}")

def traverse_module(graph, module):
    for child_module in module.get('child_modules', []):
        add_resource_node(graph, child_module)
        traverse_module(graph, child_module)

def parse_terraform_output(terraform_output):
    try:
        # Load the terraform output JSON into a Python dictionary
        data = json.loads(terraform_output)
        
        # Create a graph
        graph = nx.Graph()

        # Traverse and add nodes
        traverse_module(graph, data['values']['root_module'])
        
        # Set up the plot
        plt.figure(figsize=(10, 10))
        nx.draw(graph, with_labels=True, node_size=2000, node_color="skyblue", font_size=10)
        
        # Save the plot as an image file (PNG)
        output_file = 'terraform_resource_diagram.png'
        plt.title("Terraform Resource Diagram")
        plt.savefig(output_file)
        
        print(f"Diagram saved as {output_file}")
        
    except KeyError as e:
        print(f"KeyError: Missing key {e}")
    except json.JSONDecodeError:
        print("Error: Invalid JSON format")

# Example Terraform JSON output (replace with actual output)
terraform_output = '''{
    "values": {
        "root_module": {
            "child_modules": [
                {
                    "type": "aws_instance",
                    "name": "example_instance",
                    "other_data": "..."
                },
                {
                    "type": "aws_security_group",
                    "name": "example_sg",
                    "other_data": "..."
                }
            ]
        }
    }
}'''

parse_terraform_output(terraform_output)
