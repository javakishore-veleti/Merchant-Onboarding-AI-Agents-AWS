import os
import json
import base64
import boto3
from typing import List, Dict, Any
from botocore.config import Config

from ..interfaces.classifier import IClassifier, ClassificationInput, ClassificationOutput


class BedrockClassifier(IClassifier):
    """
    Document classifier using Amazon Bedrock with Claude.
    
    Uses Claude's vision capabilities to classify document images/PDFs.
    """
    
    # Confidence threshold below which human review is required
    CONFIDENCE_THRESHOLD = 0.85
    
    # Document types we can classify
    VALID_DOCUMENT_TYPES = [
        'BUSINESS_LICENSE',
        'BANK_STATEMENT',
        'VOIDED_CHECK',
        'TAX_RETURN',
        'DRIVERS_LICENSE',
        'ARTICLES_OF_INCORPORATION',
        'OTHER',
        'UNKNOWN'
    ]
    
    def __init__(self, profile_name: str = None, region: str = None):
        """
        Initialize Bedrock classifier.
        
        Args:
            profile_name: AWS profile name (default: moaaa_api_services)
            region: AWS region (default: from profile or us-east-1)
        """
        self.profile_name = profile_name or os.environ.get('AWS_PROFILE', 'moaaa_api_services')
        self.region = region or os.environ.get('AWS_REGION', 'us-east-1')
        
        # Create boto3 session with profile
        self.session = boto3.Session(profile_name=self.profile_name)
        
        # Configure retry settings
        config = Config(
            retries={'max_attempts': 3, 'mode': 'adaptive'}
        )
        
        # Create clients
        self.bedrock_client = self.session.client(
            'bedrock-runtime',
            region_name=self.region,
            config=config
        )
        
        self.s3_client = self.session.client(
            's3',
            region_name=self.region
        )
        
        # Model ID for Claude
        self.model_id = 'anthropic.claude-3-sonnet-20240229-v1:0'
    
    def _get_document_from_s3(self, bucket: str, key: str) -> bytes:
        """Download document from S3."""
        response = self.s3_client.get_object(Bucket=bucket, Key=key)
        return response['Body'].read()
    
    def _get_media_type(self, filename: str) -> str:
        """Determine media type from filename."""
        lower_name = filename.lower()
        if lower_name.endswith('.pdf'):
            return 'application/pdf'
        elif lower_name.endswith('.png'):
            return 'image/png'
        elif lower_name.endswith('.jpg') or lower_name.endswith('.jpeg'):
            return 'image/jpeg'
        elif lower_name.endswith('.gif'):
            return 'image/gif'
        elif lower_name.endswith('.webp'):
            return 'image/webp'
        else:
            return 'application/octet-stream'
    
    def _build_classification_prompt(self) -> str:
        """Build the classification prompt."""
        return """You are a document classification expert for a payment processing company.

Analyze the provided document and classify it into ONE of these categories:
- BUSINESS_LICENSE: Business license, operating permit, or similar government-issued business authorization
- BANK_STATEMENT: Bank account statement showing transactions and balances
- VOIDED_CHECK: A voided check showing routing and account numbers
- TAX_RETURN: Tax return documents (1040, W-2, 1099, etc.)
- DRIVERS_LICENSE: Driver's license or state ID
- ARTICLES_OF_INCORPORATION: Articles of incorporation, certificate of formation, or similar
- OTHER: A valid business document that doesn't fit the above categories
- UNKNOWN: Cannot determine what this document is

Respond with ONLY a JSON object in this exact format:
{
    "document_type": "<one of the types above>",
    "confidence": <number between 0 and 1>,
    "reasoning": "<brief explanation of why you chose this classification>"
}

Important:
- Be precise with confidence scores
- If the document is blurry, partial, or unclear, lower your confidence
- If you're unsure, use UNKNOWN with low confidence
"""
    
    def classify(self, input_data: ClassificationInput) -> ClassificationOutput:
        """
        Classify a single document using Bedrock Claude.
        
        Args:
            input_data: Classification input with S3 location
            
        Returns:
            ClassificationOutput with document type and confidence
        """
        try:
            # Get document from S3
            document_bytes = self._get_document_from_s3(
                input_data.s3_bucket, 
                input_data.s3_key
            )
            
            # Encode as base64
            document_base64 = base64.standard_b64encode(document_bytes).decode('utf-8')
            
            # Get media type
            media_type = self._get_media_type(input_data.filename)
            
            # Build request for Claude
            messages = [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": document_base64
                            }
                        },
                        {
                            "type": "text",
                            "text": self._build_classification_prompt()
                        }
                    ]
                }
            ]
            
            # Call Bedrock
            response = self.bedrock_client.invoke_model(
                modelId=self.model_id,
                contentType='application/json',
                accept='application/json',
                body=json.dumps({
                    "anthropic_version": "bedrock-2023-05-31",
                    "max_tokens": 1024,
                    "messages": messages
                })
            )
            
            # Parse response
            response_body = json.loads(response['body'].read())
            assistant_message = response_body['content'][0]['text']
            
            # Parse JSON from response
            result = json.loads(assistant_message)
            
            document_type = result.get('document_type', 'UNKNOWN').upper()
            confidence = float(result.get('confidence', 0.0))
            
            # Validate document type
            if document_type not in self.VALID_DOCUMENT_TYPES:
                document_type = 'UNKNOWN'
            
            # Determine if review is needed
            requires_review = confidence < self.CONFIDENCE_THRESHOLD
            
            return ClassificationOutput(
                document_type=document_type,
                confidence_score=confidence,
                requires_review=requires_review,
                raw_response=result
            )
            
        except Exception as e:
            # Return UNKNOWN on error
            return ClassificationOutput(
                document_type='UNKNOWN',
                confidence_score=0.0,
                requires_review=True,
                raw_response={'error': str(e)}
            )
    
    def classify_batch(self, input_data_list: List[ClassificationInput]) -> List[ClassificationOutput]:
        """
        Classify multiple documents.
        
        Args:
            input_data_list: List of classification inputs
            
        Returns:
            List of classification outputs
        """
        results = []
        for input_data in input_data_list:
            result = self.classify(input_data)
            results.append(result)
        return results
