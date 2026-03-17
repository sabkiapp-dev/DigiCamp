from decimal import Decimal
import json
import random
from django.http import JsonResponse
import requests
from rest_framework.decorators import api_view
from rest_framework.parsers import JSONParser
from ..models.call_status import CallStatus
from ..models.call_dtmf_status import CallDtmfStatus
from ..models.campaign import Campaign
from ..models.user_hosts import UserHosts
from ..models.phone_dialer import PhoneDialer
from ..serializers import CallStatusSerializer
from django.utils import timezone
from src.mytime import get_mytime
from src.phone_dialer import get_all_active_hosts, update_final_call_status, get_user_host_response, update_phone_dialer_and_sim_info
from django.conf import settings
from datetime import timedelta
from ..views.sms_dialer import sms_dialer_bulk
from threading import Thread
from ..models.sim_information import SimInformation
from ..models.dial_plan import DialPlan
from django.db.models import F
from api.jwt_token_service import JWTTokenService



def check_sim_block_call(user_host, port):
    """
    Make a test call to check if SIM is blocked.
    Uses JWT authentication.
    """
    # Generate JWT token for host authentication
    try:
        auth_token = JWTTokenService.generate_token_for_host(user_host.host)
    except Exception as e:
        print(f"Error generating JWT token for {user_host.host}: {e}")
        return

    # Set up headers with JWT token
    headers = {
        'Authorization': f'Bearer {auth_token}',
        'Content-Type': 'application/json',
    }

    # Call new endpoint /api/call/make with JWT auth
    url = f"https://{user_host.host}.sabkiapp.com/api/call/make"

    # Data payload - note: system_password is kept for backward compatibility
    # but JWT authentication is now used
    data = {
        "host": user_host.host,
        "phone_number": 8929897587,
        "port": port,
        "user_id": 10005055,
        "campaign_id": 1000000001,
        "name": "",
        "name_spell": 0
    }
    print("make_call_data : ", data)

    if port != 0:
        response = requests.post(url, headers=headers, data=json.dumps(data))
        print("make_call_reponse : ", response.json())



@api_view(['POST'])
def send_call_status(request):
    """
    Receive call status callbacks from gateway hosts.
    Now supports JWT authentication in addition to legacy password auth.
    """
    data = JSONParser().parse(request)
    host = data.get('host')
    campaign_id = data.get('campaign')

    # Get JWT token from Authorization header
    auth_header = request.headers.get('Authorization', '')
    jwt_token = None
    if auth_header.startswith('Bearer '):
        jwt_token = auth_header[7:]

    # create a random 10 digit number for testing
    random_id = ''.join([str(random.randint(0, 9)) for _ in range(10)])

    # Try JWT authentication first, then fall back to password-based auth
    user_host = None
    user_id = None

    if jwt_token:
        # Try JWT authentication
        try:
            # Extract host from token to verify it matches
            token_host = JWTTokenService.extract_host_from_token(jwt_token)
            if token_host and token_host == host:
                # Verify the token
                payload = JWTTokenService.verify_host_token(jwt_token, host)
                # Get user_host using the host
                user_host = UserHosts.objects.get(host=host)
                user_id = payload.get('user_id')
                print(f"JWT Authentication successful for host: {host}")
            else:
                print(f"JWT token host mismatch: token={token_host}, data={host}")
        except Exception as e:
            print(f"JWT authentication failed: {e}")
            # Fall through to password-based auth
            jwt_token = None

    # If JWT failed or not provided, try password-based authentication (legacy)
    if not user_host:
        system_password = data.get('system_password')
        print(f"Extracted host: {host}, system_password: {system_password}, campaign_id: {campaign_id}")

        try:
            campaign = Campaign.objects.get(id=campaign_id)
            user_id = campaign.user_id
            print(f"random id : {random_id}, phone : {data.get('phone')}, host: {host}, system_password: {system_password}, event : {data.get('event')} campaign_id: {campaign_id}, user_id : ", user_id)
            user_host = UserHosts.objects.get(host=host, system_password=system_password, user_id=user_id)
        except (Campaign.DoesNotExist, UserHosts.DoesNotExist):
            print(f"Host not matching with user_id or password not correct random id : {random_id}")
            return JsonResponse({"message": 'Host not matching with user_id or password not correct'}, status=400)


    current_time = get_mytime()
    phone = data.get('phone')
    port = data.get('port')
    sim_imsi = data.get('sim_imsi')
    data['host'] = user_host.id
    host = user_host.id
    campaign_id = data.get('campaign')  # Assuming campaign_id is in data

    
    if(data.get('event') == 'start_dialing'):
        dtmf_response = data.get('dtmf_response')
        if not dtmf_response or not dtmf_response.isdigit():
            print("Invalid dtmf_response")
            return JsonResponse({"message": 'Invalid dtmf_response'}, status=400)
        try:
            dial_time = timezone.datetime.fromtimestamp(int(dtmf_response))
        except ValueError:
            print("Invalid time format in dtmf_response.")
            dial_time = None
        if not dial_time:
            print("Invalid dtmf_response1")
            return JsonResponse({"message": 'Invalid dtmf_response'}, status=400)
     

        phone_dialer = PhoneDialer.objects.filter(phone_number=phone, campaign_id=campaign_id, sent_status=1).order_by('-sent_datetime').first()
        if not phone_dialer:
            print("random id :", random_id,", Invalid start_dialing event, phone= ", phone, " campaign= ", campaign_id, "sim_imsi= ", sim_imsi)
            return JsonResponse({"message": 'Invalid start_dialing event'}, status=400)
        print("radom_id ", random_id,"valid start_dialing event. phone= ", phone, " campaign= ", campaign_id, "sim_imsi= ", sim_imsi)
        phone_dialer.sent_datetime = dial_time
        phone_dialer.save()
        return JsonResponse({"message": 'Dial time updated successfully'}, status=201)
        
    elif data.get('event') == 'not_answered':
        # print("hereee")
        data['start_time'] = current_time
        data['end_time'] = current_time

        dtmf_response = data.get('dtmf_response')
        if not dtmf_response or not dtmf_response.isdigit():
            print("Invalid dtmf_response2")
            return JsonResponse({"message": 'Invalid timestamp'}, status=400)
        try:
            dial_time = timezone.datetime.fromtimestamp(int(dtmf_response))
        except ValueError:
            print("Invalid time format in dtmf_response.")
            dial_time = None
        if not dial_time:
            print("Invalid dtmf_response3")
            return JsonResponse({"message": 'Invalid dtmf_response'}, status=400)
       
        # Retrieve the PhoneDialer instance
        phone_dialer = PhoneDialer.objects.filter(
            phone_number=phone,
            campaign_id=campaign_id,
            sent_status=1,
            sent_datetime__gte=current_time-timedelta(hours=1)
        ).order_by('-sent_datetime').first()

        if phone_dialer:

            # print("here ")
            # if dialtime - sent_datetime is less than 5 sec, print hello world
            if (dial_time - phone_dialer.sent_datetime).total_seconds() < 5:
                if phone_dialer.block_trials > 1:
                    phone_dialer.sent_status = 2
                    phone_dialer.save()
                    return JsonResponse({"message": 'Call not answered'}, status=201)
              
                update_phone_dialer_and_sim_info(phone_dialer, user_host, sim_imsi, port)
                
                get_user_host_response(user_host)
                print("Sim blocked")
                return JsonResponse({"message": 'Sim Blocked'}, status=400)
            
            

            # If phone_dialer.
            extension = data.get('extension')
            if (extension != 'CONGESTION' and extension != 'CHANUNAVAIL'):
            
                # Update sent_status in PhoneDialer table
                phone_dialer.sent_status = 2
                phone_dialer.save()
                sim_info = SimInformation.objects.filter(host=user_host.host, sim_imsi=sim_imsi).first()
                if sim_info:
                    if sim_info.today_block_status > 3:
                        print("user_host, port : ", user_host, port)
                        check_sim_block_call(user_host, port)
                    sim_info.calls_made_today += 1
                    sim_info.calls_made_total += 1
                    sim_info.today_block_status += Decimal('0.5')
                    sim_info.save()

                # Check if allow_repeat is greater than phone_dialer.trials
                if campaign.allow_repeat > phone_dialer.trials:
                    #if sent_status=0 and campaign_id=campaign_id is already present, return
                    if PhoneDialer.objects.filter(
                        phone_number=phone,
                        campaign_id=campaign_id,
                        sent_status=0
                    ).exists():
                        return JsonResponse({"message": 'Call not answered'}, status=201)
                    # also check sent_status=1
                    # Add a new entry to PhoneDialer with sent_status 0
                    new_phone_dialer = PhoneDialer.objects.create(
                        phone_number=phone,
                        user_id=user_id,
                        name=phone_dialer.name,
                        call_through=phone_dialer.call_through,
                        campaign_id=campaign_id,
                        sent_status=0,
                        sent_datetime=current_time + timedelta(hours=1),  # 1 hour after
                        trials=phone_dialer.trials + 1  # Increment trials
                    )
                    new_phone_dialer.save()
                else:
                    # Check if there are any contacts with status 0 or 1
                    has_contacts = PhoneDialer.objects.filter(
                        campaign_id=campaign_id,
                        sent_status__in=[0, 1, 3]  # Considering status 0 and 1
                    ).exists()

                    if not has_contacts and campaign.status==1:
                        # Update campaign status to 3 if there are no contacts with status 0 or 1
                        campaign.status = 3
                        campaign.save()

                get_user_host_response(user_host)
                return JsonResponse({"message": 'Call not answered'}, status=201)
            elif(extension == 'CONGESTION' or extension == 'CHANUNAVAIL'):
                # Assuming phone_dialer is defined here
                update_phone_dialer_and_sim_info(phone_dialer, user_host, sim_imsi, port)
                get_user_host_response(user_host)
                print("Sim blocked1")
                return JsonResponse({"message": 'Sim blocked'}, status=400)    
            
        else:
            return JsonResponse({"message": 'No contact found in phone_dialer'}, status=404)


    elif data.get('event') == 'answered':
        data['start_time'] = current_time
        print("phone : ", phone, "campaign_id : ", campaign_id)
        print("")

        # Retrieve the PhoneDialer instance
        phone_dialer = PhoneDialer.objects.filter(
            phone_number=phone,
            campaign_id=campaign_id,
            sent_status=1,
            sent_datetime__gte=current_time-timedelta(hours=1)
        ).order_by('-sent_datetime').first()

        if phone_dialer:
            data['dial'] = phone_dialer.id  # Add the dial_id to the data
            print("phone number in dialer : ", phone_dialer.phone_number)
            serializer = CallStatusSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                print("phone number in serializer ", phone_dialer.phone_number)
                # Update sent_status in PhoneDialer table
                phone_dialer.sent_status = 3
                phone_dialer.save()
                print("phone number in dialer after save ", phone_dialer.phone_number)

                return JsonResponse(serializer.data, status=201)

            else:
                print("Serializer not valid : ", serializer.errors)
                phone_dialer.sent_status = 2
                phone_dialer.save()



        else:
            return JsonResponse({"message": 'No contact found in phone_dialer'}, status=404)

    elif data.get('event') == 'completed':
        timeout = campaign.call_cut_time if campaign.call_cut_time else 0
        start_time = current_time
        call_status = CallStatus.objects.filter(phone=phone, campaign=campaign, port=port, host=host, dial__sent_status=3).order_by('-id').first()
        if not call_status:
            print("Invalid event")
            return JsonResponse({"message": 'Invalid event'}, status=400)
        data['end_time'] = current_time 
        start_time = call_status.start_time
        end_time = data.get('end_time')
        data['duration'] = (end_time - start_time).seconds
        if(data['duration'] > timeout):
            data['duration'] = timeout
        duration = data['duration']
        
        # Retrieve the PhoneDialer instance
        phone_dialer = PhoneDialer.objects.filter(id=call_status.dial_id, sent_status=3).first()
        if phone_dialer:
            sim_info = SimInformation.objects.filter(host=user_host.host, sim_imsi=sim_imsi).first()

            if sim_info:
                sim_info.calls_made_today += 1
                sim_info.call_time_today += data['duration']
                sim_info.calls_made_total += 1
                sim_info.call_time_total += data['duration']
                sim_info.today_block_status = 0
                sim_info.save()

             # Update sent_status in PhoneDialer table
            phone_dialer.sent_status = 5
            phone_dialer.duration = duration
            phone_dialer.save()
            get_user_host_response(user_host)

            # Check if there are any contacts with status 0 or 1
            has_contacts = PhoneDialer.objects.filter(
                campaign_id=campaign_id,
                sent_status__in=[0, 1, 3]  # Considering status 0 and 1
            ).exists()

            if not has_contacts and campaign.status == 1:
                # Update campaign status to 3 if there are no contacts with status 0 or 1
                campaign.status = 3
                campaign.save()
                

            # Delete the existing call_status instance
            call_status.delete()


            get_user_host_response(user_host)
            return JsonResponse({"message":"Event completed"}, status=201)
        else:
            return JsonResponse({"message": 'No contact found in phone_dialer with sent_status=3'}, status=404)


    elif data.get('event') == 'dtmf':
        extension = data.get('extension')
        # If extension is not present in data, return error
        if not extension:
            return JsonResponse({"message": 'Extension is required'}, status=400)
        dtmf_response = data.get('dtmf_response')
        if not dtmf_response or not dtmf_response.isdigit() or int(dtmf_response) not in range(0, 10):
            return JsonResponse({"message": 'Invalid dtmf_response'}, status=400)
        phone_dialer = PhoneDialer.objects.filter(phone_number=phone, campaign=campaign, sent_status__in=[3, 5], sent_datetime__gte=current_time-timedelta(hours=1)).order_by('-sent_datetime').first()
        if not phone_dialer:
            return JsonResponse({"message": 'Invalid dtmf event'}, status=400)
        # Check if the campaign_id has extension in it in dialplan
        # Get the dtmf field name
        dtmf_field = f"dtmf_{dtmf_response}"

        # Check if the DialPlan exists with the given campaign, extension and dtmf response
        dial_plan_exists = DialPlan.objects.filter(
            campaign=campaign,
            extension_id=extension,
            **{dtmf_field: F(dtmf_field)}
        ).exists()

        if not dial_plan_exists:
            return JsonResponse({"message": 'Invalid dtmf event'}, status=400)

        dial_id = phone_dialer.id
        print("dial_id : ", dial_id)
        # If call_id and extension already present in call_dtmf_status table, then update the dtmf_response 
        # else insert the new record
        call_dtmf_status = CallDtmfStatus.objects.filter(call_id=dial_id, extension=extension).first()
        print("call_dtmf_status : ", call_dtmf_status)
        if call_dtmf_status:
            call_dtmf_status.dtmf_response = dtmf_response
            call_dtmf_status.save()
            return JsonResponse({'message': 'DTMF response updated successfully'}, status=201)
        else:
            call_dtmf_status = CallDtmfStatus(call_id=phone_dialer, extension=extension, dtmf_response=dtmf_response)
            call_dtmf_status.save()
            return JsonResponse({'message': 'DTMF response saved successfully'}, status=201)
    else:
        return JsonResponse({"message": 'No event found'}, status=400)

    return JsonResponse({"message": 'Unexpected error occurred'}, status=500)



def reboot_active_host():
    """
    Reboot all active hosts.
    Uses JWT authentication for API calls.
    """
    active_hosts = UserHosts.objects.filter().values('host').distinct()
    for host_dict in active_hosts:
        host = host_dict['host']

        # Generate JWT token for host authentication
        try:
            auth_token = JWTTokenService.generate_token_for_host(host)
        except Exception as e:
            print(f"Error generating JWT token for {host}: {e}")
            continue

        # Set up headers with JWT token
        headers = {
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/json',
        }

        # call the api {host}.sabkiapp.com/api/status/tunnel (no auth needed)
        response = requests.get(f'https://{host}.sabkiapp.com/api/status/tunnel')

        # if the response is not 200, leave else call the reboot api
        if response.status_code != 200:
            continue

        # call the reboot api with JWT auth
        reboot_response = requests.post(
            f'https://{host}.sabkiapp.com/api/admin/reboot',
            headers=headers,
            json={'host': host}
        )

        # check the reboot response
        if reboot_response.status_code != 200:
            print(f'Failed to reboot {host}')
        

@api_view(['GET'])
def trigger_dialer(request):
    api_key = request.GET.get('api_key')
    if api_key != settings.API_KEY_CRONJOB:
        return JsonResponse({'status': "message", 'message': 'Invalid API key'}, status=400)

    # if get_my_time() is less than 7am and greater than 10pm, return message 
    if get_mytime().hour < 7 or get_mytime().hour > 22:
        # If get_my_time hr is 5 and min is 30, call the reboot function
        if get_mytime().hour == 5 and get_mytime().minute == 30:
            Thread(target=reboot_active_host).start()
        return JsonResponse({'status': "message", 'message': 'Dialer is not allowed to run between 10pm and 7am'}, status=400)

        

    Thread(target=get_all_active_hosts).start()
    Thread(target=update_final_call_status).start()
    Thread(target=sms_dialer_bulk).start()


    return JsonResponse({'status': 'success'}, status=200)
