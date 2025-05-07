.PHONY: build build-multi run test clean install-deps lint push-quay login-quay push-quay-multi

# Docker image name and tag
IMAGE_NAME = dumb-flask-app
IMAGE_TAG = latest
QUAY_REPO = quay.io/haoliu/$(IMAGE_NAME)
PLATFORMS = linux/amd64,linux/arm64

# Build the Docker image
build:
	docker build --load -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run the Docker container
run:
	docker run -p 8080:5000 $(IMAGE_NAME):$(IMAGE_TAG)

# Run the Docker container in detached mode
run-detached:
	docker run -d -p 8080:5000 --name $(IMAGE_NAME) $(IMAGE_NAME):$(IMAGE_TAG)

# Stop the detached container
stop:
	docker stop $(IMAGE_NAME) || true
	docker rm $(IMAGE_NAME) || true

# Install Python dependencies locally
install-deps:
	pip install -r requirements.txt

# Run the application locally
run-local:
	python app.py

# Run tests (placeholder for future tests)
test:
	@echo "Running tests..."
	# Add test commands here

# Lint the code
lint:
	@echo "Linting code..."
	# Add linting commands here (e.g., flake8, pylint)

# Clean up
clean:
	@echo "Cleaning up..."
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

# Login to Quay.io
login-quay:
	@echo "Logging in to Quay.io..."
	@docker login quay.io

# Tag and push to Quay.io
push-quay: build
	@echo "Tagging and pushing to Quay.io..."
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(QUAY_REPO):$(IMAGE_TAG)
	docker push $(QUAY_REPO):$(IMAGE_TAG)

# Build multi-architecture Docker image (local testing)
build-multi:
	@echo "Building multi-architecture Docker image..."
	docker buildx create --name multiarch-builder --use || true
	docker buildx inspect --bootstrap
	# Build for the current platform only with --load
	docker buildx build -t $(IMAGE_NAME):$(IMAGE_TAG) --load .

# Push multi-architecture image to Quay.io
push-quay-multi: login-quay
	@echo "Building and pushing multi-architecture image to Quay.io..."
	docker buildx create --name multiarch-builder --use || true
	docker buildx inspect --bootstrap
	docker buildx build --platform $(PLATFORMS) -t $(QUAY_REPO):$(IMAGE_TAG) --push .
