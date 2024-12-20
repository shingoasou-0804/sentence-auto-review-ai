#!/bin/bash
set -xe

if [ -z "$1" ]; then
  echo "Empty system prompt"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Empty target question"
  exit 1
fi

system=`cat $1`
question=`cat $2`

body=`jq -n --arg system "${system}" --arg question "${question}" \
  '{
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 8192,
    "system": $system,
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": $question
          }
        ]
      }
    ]
  }'
`

aws bedrock-runtime invoke-model \
  --model-id "${AWS_BEDROCK_MODEL_ID}" \
  --content-type "application/json" \
  --body "${body}" \
  outfile.json \
  --region "${AWS_BEDROCK_REGION}" \
  --cli-binary-format raw-in-base64-out
