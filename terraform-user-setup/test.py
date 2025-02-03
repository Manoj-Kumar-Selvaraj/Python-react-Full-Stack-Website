from diagrams import Diagram
from diagrams.aws.storage import S3

with Diagram("AWS Example", outformat="svg", filename="aws_diagram"):
    S3("My S3 Bucket")
