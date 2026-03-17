import json
from django.http import JsonResponse
import requests
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import IsAuthenticated
from ..models import UserHosts
from api.jwt_token_service import JWTTokenService


def make_call(host, user_id, port, phone_number, campaign_id, name, name_spell):
    """
    Make a call to a gateway host using JWT authentication.
    Uses the new /api/call/make endpoint with Bearer token authentication.
    """
    # Generate JWT token for host authentication
    try:
        auth_token = JWTTokenService.generate_token_for_host(host)
    except Exception as e:
        print(f"Error generating JWT token for {host}: {e}")
        # Return error response
        return type('Response', (), {'status_code': 500, 'json': lambda: {'error': str(e)}})()

    # Set up headers with JWT token
    headers = {
        'Authorization': f'Bearer {auth_token}',
        'Content-Type': 'application/json',
    }

    # Call new endpoint /api/call/make with JWT auth
    url = f"https://{host}.sabkiapp.com/api/call/make"

    # Data payload - note: system_password is kept for backward compatibility
    # but JWT authentication is now used
    data = {
        "host": host,
        "user_id": user_id,
        "port": port,
        "phone_number": phone_number,
        "campaign_id": campaign_id,
        "name": name,
        "name_spell": name_spell
    }
    response = requests.post(url, headers=headers, data=json.dumps(data))
    return response


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def test_blocked_sim(request):
    # Get user_id from token
    user_id = request.user.id

    # Get data from request body
    host = request.data.get('host')
    port = request.data.get('port')
    phone_number = request.data.get('phone_number')
    print("user_id : ", user_id)
    print("host : ", host)
    print("port : ", port)
    print("phone_number : ", phone_number)

    # get system_password for the host from UserHosts
    try:
        user_host = UserHosts.objects.get(user_id=user_id, host=host)
    except UserHosts.DoesNotExist:
        return JsonResponse({'message': 'Host not found or not associated with this user'}, status=404)

    campaign_id = 1000000001

    make_call_response = make_call(host, user_id, port, phone_number, campaign_id, "", 0)
    if make_call_response.status_code == 200:
        return JsonResponse({'message': make_call_response.json()}, status=200)
    else:
        return JsonResponse({'message': 'Error in make_call'}, status=make_call_response.status_code)
