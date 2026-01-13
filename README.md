# KeepAlive Repo

## Overall Purpose

This repository contains a simple but complete **Node.js web service** designed to be monitored, along with an **automated testing pipeline** to ensure it's running correctly. It serves as a foundational example of a reliable microservice.

## Core Functionality

### 1. Health Check Service (`index.js`)

- This is a lightweight web server built using the Express.js framework.
- It has a single purpose: to expose a `/health` endpoint.
- When you make a request to `http://<server-address>:3000/health`, it responds with a `200 OK` status and a simple JSON message: `{"status":"ok"}`.
- This "health check" is a standard industry pattern used by monitoring tools (like Kubernetes, load balancers, or uptime checkers) to verify that a service is running and responsive.

### 2. Automated Test Suite (`tests/run_tests.sh`)

- To guarantee the health check service works, the repository includes a test script.
- This script automatically:
  1.  Starts the Node.js server in the background.
  2.  Waits a moment for it to initialize.
  3.  Acts like a monitoring tool by sending a request to the `/health` endpoint.
  4.  Checks that the response is `200 OK` and the body is `{"status":"ok"}`.
  5.  Stops the server.
- If the checks pass, the test is successful; otherwise, it fails.

### 3. CI/CD Integration (`.gitlab-ci.yml`)

- The project is configured with a GitLab CI pipeline.
- On every code change, this pipeline automatically sets up a Node.js environment, installs the required dependencies, and runs the test suite.
- This ensures that no changes can be merged that would break the core functionality of the health check service.

In summary, the repository provides a **runnable Node.js service with a health check endpoint and a fully integrated, automated test suite to validate its behavior.**
