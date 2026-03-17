import jwt
from django.conf import settings
from django.contrib.auth.models import User
from rest_framework.authentication import get_authorization_header
from rest_framework.exceptions import AuthenticationFailed
from .models.users import Users
def auth_wrapper(request):
    auth_data = get_authorization_header(request).decode('utf-8')
    

    if not auth_data or 'Bearer ' not in auth_data:
        raise AuthenticationFailed("Authorization token not provided")
    
    token = auth_data.split(' ')[1]
  
   

    try:
        # Specify the algorithm to decode the token
        user_id = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])['user_id']
        user = Users.objects.get(id=user_id, status=1)
 
        return user.id
    except jwt.DecodeError as e:
        print(f"JWT Decode Error: {str(e)}")
        raise AuthenticationFailed("Invalid token")
    except jwt.ExpiredSignatureError as e:
        print(f"JWT Expiry Error: {str(e)}")
        raise AuthenticationFailed("Token has expired")
    except User.DoesNotExist as e:
        print(f"User Error: {str(e)}")
        raise AuthenticationFailed("User not found")
