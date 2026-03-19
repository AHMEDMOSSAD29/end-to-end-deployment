#!/bin/bash

# --- Configuration Variables ---
# Replace these with your specific details
AWS_REGION="us-east-1"
# For Bitbucket: oidc.bitbucket.org
# For GitHub: token.actions.githubusercontent.com
# For GitLab: gitlab.com
OIDC_PROVIDER_URL="oidc.bitbucket.org" 
ROLE_NAME="app-1-oidc-role"
ECR_REPOSITORY_ARN="arn:aws:ecr:${AWS_REGION}:<YOUR_ACCOUNT_ID>:repository/dev/app-1"

echo "Step 1: Creating OIDC Identity Provider..."
# Note: This only needs to be run once per AWS account for each provider
aws iam create-open-id-connect-provider \
    --url "https://${OIDC_PROVIDER_URL}" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "A031C46782E6E6C662C2C87C76DA9AA62CCABD8E" # Standard Bitbucket thumbprint

echo "Step 2: Creating Trust Policy..."
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<YOUR_ACCOUNT_ID>:oidc-provider/${OIDC_PROVIDER_URL}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "${OIDC_PROVIDER_URL}:sub": "your-bitbucket-workspace-id:*"
        }
      }
    }
  ]
}
EOF

echo "Step 3: Creating IAM Role..."
aws iam create-role --role-name ${ROLE_NAME} --assume-role-policy-document file://trust-policy.json

echo "Step 4: Attaching ECR Permissions to Role..."
cat <<EOF > ecr-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "${ECR_REPOSITORY_ARN}"
        }
    ]
}
EOF

aws iam put-role-policy --role-name ${ROLE_NAME} --policy-name ECRPushPolicy --policy-document file://ecr-policy.json

echo "Setup Complete! Your AWS_ROLE_ARN is: arn:aws:iam::<YOUR_ACCOUNT_ID>:role/${ROLE_NAME}"