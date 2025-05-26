                             +--------------------------------+
                             |   Select ADO Agent Deployment  |
                             +--------------------------------+
                                       |
                +----------------------+----------------------+
                |                                             |
         EC2-Based ADO Agent                       EKS-Based ADO Agent (HPA Capable)
                |                                             |
        +------------------+                        +---------------------------+
        | Key Use Cases:   |                        | Key Use Cases:            |
        |------------------|                        |---------------------------|
        | - Stable workloads                        | - Dynamic, bursty workloads
        | - Easier debugging                        | - Microservices CI/CD
        | - Legacy integration                      | - Auto-scaling needed
        | - No container needs                      | - Cloud-native setups
                |                                             |
        +------------------+                        +---------------------------+
        | Setup Steps:      |                       | Setup Steps:               |
        |------------------|                       |----------------------------|
        | A. Use Terraform to spin up              | A. Allow dynamic creation of
        |    EC2 with predefined AMI               |    agent pods on EKS
        | B. Update the ADO agent pool ID          | B. Integrate Kubernetes agent
        |    to connect EC2 to ADO                 |    with ADO pipeline
        | C. Configure ADO connection              | C. Configure Horizontal Pod
        |    via Proxy Server                      |    Autoscaler (HPA)
        | D. Whitelist package URLs                | D. Use node group with
        |    (some may already exist)              |    appropriate IAM policies
        | E. Apply Arcos IAM policies via          | E. Monitor pod scaling and
        |    EC2 Instance Profile                  |    performance metrics
        | F. Request Arcos onboarding              | F. Ensure EKS and ADO tokens
        |    for login compliance                  |    are securely managed
    
