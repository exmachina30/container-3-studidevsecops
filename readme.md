# simple-app - NodeJS App 

## Introduction

**Simple App** is a minimalistic application designed to demonstrate essential features and best practices in modern software development. This project provides a clean example of building, containerizing, and deploying a basic app using Docker and Kubernetes. It aims to serve as both an educational tool and a practical starting point for developers looking to understand the basics of containerization and cloud-native deployment.

## Prerequisites

To work with the Simple App, you’ll need to have the following tools and services set up:

1.  **Git**: For version control and repository management.
    
    -   Installation: [Git Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
2.  **Node.js and npm**: Node.js is used for development and npm for managing dependencies.
    
    -   Installation: [Node.js Download](https://nodejs.org/)
3.  **Docker**: For containerizing the application.
    
    -   Installation: Docker Installation Guide
4.  **Google Cloud SDK**: To interact with Google Cloud services and manage GCR.
    
    -   Installation: Google Cloud SDK Installation
5.  **Helm**: A package manager for Kubernetes to manage Kubernetes applications.
    
    -   Installation: Helm Installation Guide
6.  **Google Kubernetes Engine (GKE)**: A managed Kubernetes service on Google Cloud Platform.
    
    -   Setup: GKE Quickstart

## API Specification
| API Route | Description |
|---|---|
| {base_url}/health | Return OK when the DB is connected and API is up and running |
| {base_url}/users | Return all data in `users` table, populated during the migration |

## DB Connection
The DB connection is maintained as environment variables.
```
DB_USER='username'
DB_PASSWORD='password'
DB_NAME='database_name'
DB_HOST='127.0.0.1'
DB_PORT='5432'
```

## Clone the Repository

First, clone your repository to your local machine:
```
git clone https://github.com/exmachina30/container-3-studidevsecops/
``` 

## How to run this application code locally
1. Create `.env` file in the root folder, populate from `.env.example`
2. Update `.env` file based on your DB configuration
3. Run `npm i`
4. Migrate schema: `npm run migrate`
5. Migrate data: `npm run seed`
6. Run app `npm start` 
7. Open it on `localhost:3000`

## Build and Push Docker Image to GCR

1.  **Login to Google Cloud**: Ensure you are authenticated with Google Cloud and have access to your GCR.
    ```
    gcloud auth login
    ```
    
2.  **Set Your Google Cloud Project**:
    ```
    gcloud config set project [YOUR_PROJECT_ID]
    ```
    
3.  **Build the Docker Image**: From the root directory of the project, build the Docker image.
    ```
    docker build -t gcr.io/[YOUR_PROJECT_ID]/simple-app:latest .
    ```
    
4.  **Push the Docker Image to GCR**: Push the image to Google Container Registry.
    ```
    docker push gcr.io/[YOUR_PROJECT_ID]/simple-app:latest
    ```

## Deploy Kustomize Manifest to GKE

1.  **Authenticate with GKE**: Configure `kubectl` to use your GKE cluster.
    ```
    gcloud container clusters get-credentials [CLUSTER_NAME] --zone [ZONE] --project [YOUR_PROJECT_ID]
    ```
    
1. **Install Kustomize:**
   Ensure Kustomize is installed on your machine. You can install it using the following commands:

   - **Using `kubectl`:**
     ```bash
     kubectl kustomize --version
     ```

   - **Direct Installation:**
     Follow the [official Kustomize installation guide](https://kubectl.docs.kubernetes.io/installation/kustomize/) for other methods.

2. **Prepare Kustomize Configuration:**
   Ensure that your Kustomize configurations are set up correctly. This involves defining base and overlay directories for your Kubernetes manifests.

   - **Base Configuration:**
     Your base manifests should be located in `k8s/kustomize/base`.

   - **Overlay Configuration:**
     Environment-specific configurations (e.g., `dev`, `prod`) should be in `k8s/kustomize/overlays`.

3. **Generate Kustomize Output:**
   Generate and inspect the final Kubernetes manifests from your Kustomize configurations:
   ```
   kustomize build k8s/kustomize/overlays/[ENV] > kustomize_output.yaml
   ```

4. **Apply Kustomize Configuration: Apply the generated manifests to your Kubernetes cluster:**
   ```
   kubectl apply -f kustomize_output.yaml \
    --namespace [ENV]
   ```

5.  **Verify the Deployment**: Check the status of the deployed application.
    ```
    kubectl get pods
    kubectl get services
    ```
    

## Verify Endpoints

To verify that your application is running correctly, you need to check the endpoints.

Check the `/health` endpoint:
```
curl http://<endpoint>/health 
curl http://<endpoint>/health 
```
Check the `/users` endpoint:
```
curl http://<endpoint>/users 
curl http://<endpoint>/users 
```

You should get appropriate responses if your application is correctly set up.

## Contributing

We welcome contributions to this repository. If you have suggestions or improvements, please follow these steps:

1.  **Fork the Repository**: Create your own fork of the repository.
2.  **Create a Branch**: Work on a new branch for your changes.
3.  **Commit Changes**: Commit your changes with descriptive messages.
4.  **Push to Your Fork**: Push your changes to your forked repository.
5.  **Create a Merge Request**: Open a merge request to propose your changes.

## Issues

If you encounter any issues or bugs, please report them in the [Issues section](https://github.com/exmachina30/container-3-studidevsecops/-/issues) of the repository. Provide as much detail as possible to help us resolve the problem quickly.

## Contact

For any questions or further assistance, please reach out via [GitHub issues](https://github.com/exmachina30/container-3-studidevsecops/-/issues) or email hakimrizkip@gmail.com.



