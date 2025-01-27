#!/bin/bash

# Configuration
IMAGE_NAME="${IMAGE_NAME}"
GCR_PROJECT_ID="${GCR_PROJECT_ID}"
GCR_REGION="${GCR_REGION}"
GITLAB_REPO_URL="${GITLAB_REPO_URL}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"

# Kustomize Directory (relative to the project root)
KUSTOMIZE_DIR="k8s/kustomize/overlays/${NAMESPACE}"
BASE_DIR="k8s/kustomize/base"

# Environment-specific namespace
NAMESPACE=$1

# Absolute path to the local repository
REPO_DIR_ABS="${CI_PROJECT_DIR}"

# Ensure necessary commands are available
for cmd in docker gcloud kubectl git sed kustomize; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Clone or pull from GitLab repository
if [ -d "$REPO_DIR_ABS" ]; then
    echo "Directory $REPO_DIR_ABS exists. Pulling the latest changes..."
    cd $REPO_DIR_ABS || { echo "Failed to change directory to $REPO_DIR_ABS"; exit 1; }
    git pull origin master || { echo "Failed to pull latest changes from GitLab repository"; exit 1; }
else
    echo "Directory $REPO_DIR_ABS does not exist. Cloning the repository..."
    # Ensure the parent directory exists
    mkdir -p "$(dirname $REPO_DIR_ABS)"
    git clone $GITLAB_REPO_URL $REPO_DIR_ABS || { echo "Failed to clone GitLab repository"; exit 1; }
    cd $REPO_DIR_ABS || { echo "Failed to change directory to $REPO_DIR_ABS"; exit 1; }
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to pull or clone the GitLab repository."
    exit 1
fi

# Get the latest commit hash from Git
IMAGE_TAG=$(git rev-parse --short HEAD)

if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve the Git commit hash."
    exit 1
fi

# Build Docker image
echo "Building Docker image with tag ${IMAGE_TAG}..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

if [ $? -ne 0 ]; then
    echo "Error: Docker build failed."
    exit 1
fi

# Tag Docker image for GCR
GCR_IMAGE_TAG="${GCR_REGION}-docker.pkg.dev/${GCR_PROJECT_ID}/simple-app/${IMAGE_NAME}:${IMAGE_TAG}"
echo "Tagging Docker image..."
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${GCR_IMAGE_TAG}

if [ $? -ne 0 ]; then
    echo "Error: Docker tag failed."
    exit 1
fi

# Authenticate with Google Cloud
echo "Authenticating with Google Cloud..."
gcloud auth configure-docker

if [ $? -ne 0 ]; then
    echo "Error: Google Cloud authentication failed."
    exit 1
fi

# Push Docker image to GCR
echo "Pushing Docker image to GCR..."
docker push ${GCR_IMAGE_TAG}

if [ $? -ne 0 ]; then
    echo "Error: Docker push to GCR failed."
    exit 1
fi

# Function to handle base64-encoded environment variables
apply_secrets() {
    local secret_file="k8s/kustomize/overlays/${NAMESPACE}/secret.yaml"
    local template_file="k8s/kustomize/overlays/${NAMESPACE}/secret.yaml.template"
    
    # Substitute base64-encoded environment variables into the secret template
    echo "Substituting environment variables into the secret template..."
    envsubst < "${template_file}" > "${secret_file}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate secret manifest."
        exit 1
    fi
}

# Apply the secrets
apply_secrets

# Replace placeholders in kustomization.yaml.template
echo "Replacing placeholders in kustomization.yaml.template:"
sed -e "s|\${IMAGE_NAME}|${GCR_REGION}-docker.pkg.dev/${GCR_PROJECT_ID}/simple-app/${IMAGE_NAME}|g" \
    -e "s|\${IMAGE_TAG}|${IMAGE_TAG}|g" \
    k8s/kustomize/base/kustomization.yaml.template > k8s/kustomize/base/kustomization.yaml

# Replace placeholders in deployment.yaml.template
sed -e "s|\${IMAGE_NAME}|${GCR_REGION}-docker.pkg.dev/${GCR_PROJECT_ID}/simple-app/${IMAGE_NAME}|g" \
    -e "s|\${IMAGE_TAG}|${IMAGE_TAG}|g" \
    k8s/kustomize/base/deployment.yaml.template > k8s/kustomize/base/deployment.yaml

# Generate Kustomize output
echo "Generating Kustomize output:"
kustomize build ${KUSTOMIZE_DIR} > kustomize_output.yaml

# Apply the Kustomize output
echo "Applying Kustomize configuration:"
kubectl apply -f kustomize_output.yaml --namespace "${NAMESPACE}"

if [ $? -ne 0 ]; then
    echo "Error: Kustomize apply failed."
    exit 1
fi

echo "Kustomize configuration applied successfully."
