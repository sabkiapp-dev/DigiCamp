import threading
import time
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'digicamp.settings')
django.setup()

import requests
from src.mytime import get_mytime
import json
from api.models import SmsDialer
from api.jwt_token_service import JWTTokenService
from api.models import UserHosts


class SmsSender:
    def __init__(self):
        pass

    def send_sms(self, host, password, data):
        """
        Send SMS to a gateway host using JWT authentication.
        Uses the new /api/sms/send endpoint with Bearer token authentication.

        Args:
            host: The host identifier (e.g., 'host1')
            password: Legacy password (kept for compatibility, not used for auth)
            data: SMS data to send

        Returns:
            list: Response data from the host
        """
        try:
            # Generate JWT token for host authentication
            auth_token = JWTTokenService.generate_token_for_host(host)

            # Set up headers with JWT token
            headers = {
                'Authorization': f'Bearer {auth_token}',
                'Content-Type': 'application/json'
            }

            # Prepare the payload (without password - JWT handles auth)
            payload = {
                "host": host,
                "data": data
            }

            # Call new endpoint /api/sms/send with JWT auth
            url = f'https://{host}.sabkiapp.com/api/sms/send'
            response = requests.post(url, headers=headers, data=json.dumps(payload))

            # process the response
            response_data = response.json()
            for item in response_data:
                message_data, status_code = item
                sms_dialer_id = message_data['sms_dialer_id']

                # If status_code = 200, sent_status = 5, if status_code = 421, 422 or 423, sent_status = 6, if 424 or 5xx sent_status = 0 else sent_status = 7
                if status_code == 200:
                    sent_status = 5
                elif status_code in [421, 422, 423]:
                    sent_status = 7
                elif status_code in [424, 500, 501, 502, 503, 504]:
                    sent_status = 0
                else:
                    sent_status = 8


                # Update the sent_status in the SmsDialer table to 1
                sms_dialer = SmsDialer.objects.get(id=sms_dialer_id)
                sms_dialer.sent_status = sent_status
                sms_dialer.sent_datetime = get_mytime()
                sms_dialer.save()

            return response_data
        except Exception as e:
            print(f"Error sending SMS to {host}: {str(e)}")
            # Return empty list on error to prevent crashes
            return []
