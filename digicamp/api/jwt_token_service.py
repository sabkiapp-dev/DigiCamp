"""
JWT Token Service for Ed25519 Authentication with Gateway Hosts.

This service handles:
1. Generating JWT tokens for hosts (Central -> Host communication)
2. Verifying JWT tokens from hosts (Host -> Central communication)
"""

import jwt
from datetime import datetime, timedelta
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from django.conf import settings
from api.models import UserHosts


class JWTTokenService:
    """Service for generating and verifying Ed25519 JWT tokens."""

    # Token expiration time in minutes
    TOKEN_EXPIRY_MINUTES = getattr(settings, 'JWT_HOST_TOKEN_EXPIRY_MINUTES', 5)
    # Expected audience for tokens from hosts
    EXPECTED_AUDIENCE = getattr(settings, 'JWT_HOST_EXPECTED_AUDIENCE', 'central')
    # Expected issuer for tokens from central
    EXPECTED_ISSUER = getattr(settings, 'JWT_HOST_EXPECTED_ISSUER', 'central')

    @staticmethod
    def _load_public_key_from_pem(key_data: str) -> bytes:
        """Load public key from PEM format."""
        if isinstance(key_data, str):
            key_data = key_data.encode('utf-8')
        key = serialization.load_pem_public_key(key_data, backend=default_backend())
        return key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )

    @classmethod
    def generate_token_for_host(cls, host_name: str, additional_claims: dict = None) -> str:
        """
        Generate Ed25519 JWT token for a specific host.
        Central signs with its own private key.

        Args:
            host_name: The host identifier (e.g., 'host1', 'host2')
            additional_claims: Additional claims to include in the token

        Returns:
            str: The encoded JWT token
        """
        private_key = getattr(settings, 'ED25519_PRIVATE_KEY', None)

        if not private_key:
            # Fallback to HMAC if Ed25519 key not configured
            return cls._generate_hmac_token(host_name, additional_claims)

        if additional_claims is None:
            additional_claims = {}

        # Build claims
        claims = {
            **additional_claims,
            'iat': datetime.utcnow(),
            'exp': datetime.utcnow() + timedelta(minutes=cls.TOKEN_EXPIRY_MINUTES),
            'iss': cls.EXPECTED_ISSUER,
            'aud': host_name,
        }

        # Encode with Ed25519 private key
        return jwt.encode(claims, private_key, algorithm='EdDSA')

    @classmethod
    def _generate_hmac_token(cls, host_name: str, additional_claims: dict = None) -> str:
        """Fallback HMAC token generation."""
        secret_key = getattr(settings, 'SECRET_KEY', 'fallback-secret')

        if additional_claims is None:
            additional_claims = {}

        claims = {
            **additional_claims,
            'iat': datetime.utcnow(),
            'exp': datetime.utcnow() + timedelta(minutes=cls.TOKEN_EXPIRY_MINUTES),
            'iss': cls.EXPECTED_ISSUER,
            'aud': host_name,
        }

        return jwt.encode(claims, secret_key, algorithm='HS256')

    @classmethod
    def verify_host_token(cls, token: str, host_id: str) -> dict:
        """
        Verify JWT token from a host using the host's public key.

        Args:
            token: The JWT token to verify
            host_id: The host identifier

        Returns:
            dict: The decoded payload if valid

        Raises:
            Exception: If token is invalid or host not found
        """
        # Get host's public key from database
        try:
            user_host = UserHosts.objects.get(host=host_id)
        except UserHosts.DoesNotExist:
            raise Exception(f"Host {host_id} not found")

        # Check if host has Ed25519 public key
        if user_host.ed25519_public_key:
            return cls._verify_eddsa_token(token, host_id, user_host.ed25519_public_key)
        else:
            # Fallback to password-based verification (legacy)
            raise Exception(f"Host {host_id} does not have Ed25519 public key configured")

    @classmethod
    def _verify_eddsa_token(cls, token: str, host_id: str, public_key: str) -> dict:
        """Verify Ed25519 JWT token."""
        try:
            public_pem = cls._load_public_key_from_pem(public_key)

            payload = jwt.decode(
                token,
                public_pem,
                algorithms=['EdDSA'],
                options={'verify_exp': True},
                issuer=host_id,
                audience=cls.EXPECTED_AUDIENCE,
            )
            return payload
        except jwt.ExpiredSignatureError:
            raise Exception("Token has expired")
        except jwt.InvalidIssuerError:
            raise Exception(f"Invalid issuer. Expected: {host_id}")
        except jwt.InvalidAudienceError:
            raise Exception(f"Invalid audience. Expected: {cls.EXPECTED_AUDIENCE}")
        except jwt.InvalidTokenError as e:
            raise Exception(f"Invalid token: {str(e)}")

    @classmethod
    def extract_host_from_token(cls, token: str) -> str:
        """
        Extract host_id from token without verification.
        Used to determine which host is sending the request.

        Args:
            token: The JWT token

        Returns:
            str: The host_id from the token's issuer claim
        """
        try:
            # Decode without verification to get issuer
            unverified = jwt.decode(
                token,
                options={
                    'verify_signature': False,
                    'verify_exp': False,
                    'verify_iss': False,
                    'verify_aud': False,
                }
            )
            return unverified.get('iss')
        except Exception:
            return None


# Singleton instance for easy import
jwt_token_service = JWTTokenService()
