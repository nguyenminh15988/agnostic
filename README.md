# README

## **Overview**
This project provides a scalable, fault-tolerant solution for deploying a Flask-based application in Kubernetes. It includes infrastructure provisioning using Terraform, application deployment using Helm, and monitoring with Prometheus and Grafana.

---

## **Folder Structure**
```plaintext
flask-backend/              # Flask application source code
  |- app-expose-metric.py   # Application exposing Prometheus metrics
  |- app.py                 # Main application logic
  |- Dockerfile             # Dockerfile for building the application container
  |- requirements.txt       # Python dependencies

helm/                       # Helm charts for deploying Flask app
  |- flask-backend/         # Chart for Flask application
    |- templates/           # Kubernetes templates (deployment, service, ingress, etc.)
    |- values.yaml          # Default values for Flask Helm chart

monitoring/                 # Monitoring configuration files
  |- grafana-values.yaml    # Grafana Helm chart values
  |- prometheus-values.yaml # Prometheus Helm chart values

postgresql/                 # PostgreSQL setup and TLS certificates
  |- postgres-certs/        # TLS certificates for PostgreSQL
    |- server.crt, server.key, ca.crt, etc.
  |- postgres-values.yaml   # PostgreSQL Helm chart values

terraform/                  # Terraform scripts for provisioning AWS infrastructure
  |- eks/                   # Amazon EKS (Elastic Kubernetes Service) cluster setup
    |- cluster.tf           # EKS cluster definition
    |- iam.tf               # IAM roles and policies
    |- node_group.tf        # EKS worker node group configuration
    |- main.tf              # Terraform main entry point
    |- outputs.tf           # Terraform outputs
  |- rds/                   # Amazon RDS configuration for PostgreSQL
    |- rds.tf               # RDS instance definition
    |- security_group.tf    # Security group for RDS
    |- variables.tf         # Input variables for Terraform
```

---

## **Steps to Provision the Environment**

### **1. Prerequisites**
Ensure the following tools are installed and configured:
- Terraform (>= v1.3)
- Helm (>= v3.10)
- kubectl (>= v1.24)
- AWS CLI (configured with appropriate credentials)
- Docker

### **2. Provision the AWS Infrastructure**
1. Navigate to the Terraform folder:
   ```bash
   cd terraform/eks
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the Terraform configuration to provision the EKS cluster and RDS:
   ```bash
   terraform apply
   ```
   - This creates an EKS cluster, worker nodes, and an RDS PostgreSQL instance.

4. Export the kubeconfig for the EKS cluster:
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

---

## **Instructions to Deploy and Test the Application**

### **1. Build and Push the Docker Image**
1. Build the Docker image for the Flask application:
   ```bash
   docker build -t minh15988/flask-backend:latest flask-backend/.
   ```
2. Push the image to Docker Hub:
   ```bash
   docker push minh15988/flask-backend:latest
   ```

### **2. Deploy the Application**
1. Deploy PostgreSQL:
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm install postgres bitnami/postgresql -f postgresql/postgres-values.yaml -n backend --create-namespace
   ```

2. Deploy Prometheus and Grafana for monitoring:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo add grafana https://grafana.github.io/helm-charts

   helm install prometheus prometheus-community/prometheus -f monitoring/prometheus-values.yaml -n monitoring --create-namespace
   helm install grafana grafana/grafana -f monitoring/grafana-values.yaml -n monitoring
   ```

3. Deploy the Flask application:
   ```bash
   helm install flask-backend helm/flask-backend -n backend
   ```

### **3. Test the Application**
1. Check the status of all pods:
   ```bash
   kubectl get pods -n backend
   ```

2. Verify the application is accessible via the ingress:
   ```bash
   kubectl get ingress -n backend
   ```
   - Update `/etc/hosts` with the ingress host (e.g., `flask.local`).

3. Access the application:
   - Base URL: `http://flask.local`
   - Metrics: `http://flask.local/metrics`

4. Access Grafana to view monitoring dashboards:
   ```bash
   kubectl port-forward svc/grafana 3000:3000 -n monitoring
   ```
   - Open `http://localhost:3000` in your browser.
   - Login with credentials defined in `grafana-values.yaml`.

---

## **Fault-Tolerance and Scaling Approach**

### **Fault-Tolerance**
1. **Multi-AZ Deployment**:
   - The EKS cluster and RDS instance are deployed across multiple availability zones for high availability.

2. **Replicated Services**:
   - The Flask application is deployed with multiple replicas using a Kubernetes Deployment.
   - PostgreSQL uses replication (read replicas) to ensure data availability.

3. **Health Checks**:
   - Liveness and readiness probes ensure unhealthy pods are replaced automatically.

4. **Monitoring and Alerting**:
   - Prometheus monitors metrics, and Grafana provides dashboards.
   - Alerts can be configured for critical conditions (e.g., high CPU usage, pod failures).

### **Scaling**
1. **Horizontal Scaling**:
   - Kubernetes Horizontal Pod Autoscaler (HPA) scales the Flask application based on CPU usage or custom metrics (configured in `hpa.yaml`).

2. **Vertical Scaling**:
   - Resources for the PostgreSQL database and application pods can be increased via Helm values (`resources.requests` and `resources.limits`).

3. **Event-Driven Scaling**:
   - Integration with KEDA (Kubernetes Event-Driven Autoscaling) allows scaling based on queue length, HTTP request rates, or other events.

---

## **Architectural Diagram**

```plaintext
+-----------------------------+        +-----------------------------+
|        End Users            |        |          Developers         |
+-----------------------------+        +-----------------------------+
            |                                   |
            v                                   v
  +-------------------------+          +----------------------------+
  |    Application Layer    |          | Infrastructure as Code (IaC) |
  | Flask App (Backend API) | <--------> | Terraform (EKS + RDS)       |
  +-------------------------+          +----------------------------+
            |
            v
+---------------------------+
| Kubernetes (EKS Cluster)  |
| - Pods                    |
| - Services (ClusterIP)    |
+---------------------------+
            |
            v
+--------------------------+
| PostgreSQL (Amazon RDS)  |
+--------------------------+
            |
            v
+----------------------------+
| Monitoring (Prometheus +  |
| Grafana)                  |
+----------------------------+
```

---

## **Conclusion**
This solution leverages AWS infrastructure, Kubernetes orchestration, and monitoring tools to create a scalable, fault-tolerant Flask-based application. Follow the steps outlined in this document to provision, deploy, and monitor the application effectively.

