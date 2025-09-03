# AWS Academy Lab Setup for GitHub Actions

## 🚨 IMPORTANT: AWS Academy/Lab Environment

Based on your IAC file, you're using AWS Academy Lab credentials. Here's how to properly configure them:

## 1. Get AWS Academy Credentials

1. **Access your AWS Academy Lab**
2. **Click on "AWS Details"**
3. **Copy the credentials in this format:**
   ```
   aws_access_key_id = AKIA...
   aws_secret_access_key = ...
   aws_session_token = IQoJb3JpZ2luX2VjE...
   ```

## 2. Set Up GitHub Secrets

Go to your GitHub repository settings and add these **3 secrets**:

### Required Secrets:
- **`AWS_ACCESS_KEY_ID`** = The access key from AWS Academy
- **`AWS_SECRET_ACCESS_KEY`** = The secret key from AWS Academy
- **`AWS_SESSION_TOKEN`** = The session token from AWS Academy ⚠️ **REQUIRED for Academy**

## 3. Account ID Verification

Your IAC file shows account ID: `218596482633`

**Verify this matches your current lab account:**
```bash
aws sts get-caller-identity
```

If the account ID is different, you'll need to update your IAC file.

## 4. Time Limitations

⏰ **AWS Academy sessions expire!** Typically after:
- 4 hours of inactivity
- 12-24 hours maximum

**When credentials expire:**
1. Restart your AWS Academy Lab
2. Get new credentials
3. Update GitHub secrets
4. Re-run the workflow

## 5. Testing Credentials

Test your credentials locally:
```bash
# Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"
export AWS_DEFAULT_REGION="us-east-1"

# Test
aws sts get-caller-identity
aws ecr describe-repositories --region us-east-1
```

## 6. ECR Repository Check

Ensure your ECR repository exists:
```bash
aws ecr describe-repositories --repository-names pipeline-devops --region us-east-1
```

If it doesn't exist, create it:
```bash
aws ecr create-repository --repository-name pipeline-devops --region us-east-1
```

## 7. Troubleshooting

### Common Issues:
1. **Missing Session Token** - Academy requires `AWS_SESSION_TOKEN`
2. **Expired Credentials** - Restart lab and update secrets
3. **Wrong Account ID** - Verify account matches IAC file
4. **Repository Not Found** - Create ECR repository first

### Quick Check Commands:
```bash
# Check current identity
aws sts get-caller-identity

# Check ECR repositories
aws ecr describe-repositories --region us-east-1

# Check ECS clusters
aws ecs list-clusters --region us-east-1
```

## 8. Alternative: Deploy Infrastructure First

If ECR doesn't exist, deploy your CloudFormation stack:
```bash
aws cloudformation create-stack \
  --stack-name pipeline-devops-infrastructure \
  --template-body file://iac/iac.yml \
  --parameters ParameterKey=KeyName,ParameterValue=your-key-name \
              ParameterKey=DBPassword,ParameterValue=your-db-password \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```
