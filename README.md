# StartTech Application

Full-stack application with React frontend and Golang backend.

## Application URLs

| Service | URL |
|---|---|
| Frontend | https://d7o1972s2ptl5.cloudfront.net |
| Backend API | http://production-alb-644936730.us-east-1.elb.amazonaws.com |
| Health Check | http://production-alb-644936730.us-east-1.elb.amazonaws.com/health |

## Repository Structure

- .github/workflows/frontend-ci-cd.yml - React build and S3 deployment
- .github/workflows/backend-ci-cd.yml - Golang Docker build and EC2 deployment
- frontend/ - React application
- backend/ - Golang API
- scripts/ - deployment and rollback scripts

## CI/CD Pipelines

### Frontend Pipeline
Triggered on push to main when files in frontend/ change:
1. Install dependencies
2. Run security audit
3. Run tests
4. Build production bundle
5. Sync to S3
6. Invalidate CloudFront cache

### Backend Pipeline
Triggered on push to main when files in backend/ change:
1. Run tests and code quality checks
2. Build Docker image
3. Scan for vulnerabilities
4. Push to ECR
5. Trigger rolling update on ASG
6. Run smoke tests against ALB

## GitHub Secrets Required

| Secret | Description |
|---|---|
| AWS_ACCESS_KEY_ID | AWS IAM access key |
| AWS_SECRET_ACCESS_KEY | AWS IAM secret key |

## Local Development

Frontend:
  cd frontend
  npm install
  npm start

Backend:
  cd backend
  go run ./cmd/api
