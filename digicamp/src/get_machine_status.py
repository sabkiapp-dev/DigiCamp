
import requests
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'digicamp.settings')
django.setup()

from api.jwt_token_service import JWTTokenService


def get_machine_status(user_host):
    """
    Fetch machine status from a gateway host using JWT authentication.
    Uses the new /api/status/ports endpoint with Bearer token authentication.

    Args:
        user_host: UserHosts model instance

    Returns:
        dict: Machine status data or None if request fails
    """
    try:
        # Generate JWT token for host authentication
        auth_token = JWTTokenService.generate_token_for_host(user_host.host)

        # Set up headers with JWT token
        headers = {
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/json'
        }

        # Call new endpoint /api/status/ports with JWT auth
        response = requests.get(
            f'https://{user_host.host}.sabkiapp.com/api/status/ports',
            headers=headers,
            timeout=10
        )
        return response.json()  # return the response from the server
    except requests.exceptions.RequestException as e:
        return None
