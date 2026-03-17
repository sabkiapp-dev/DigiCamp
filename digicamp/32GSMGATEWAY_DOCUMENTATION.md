# 32GSMgateway - Complete Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Project Structure](#project-structure)
4. [Core vs Machine Status Versions - KEY DIFFERENCES](#core-vs-machine-status-versions---key-differences)
5. [Database Models](#database-models)
6. [API Endpoints](#api-endpoints)
7. [Installation & Setup](#installation--setup)
8. [Configuration](#configuration)
9. [Running the System](#running-the-system)
10. [Gateway Server API](#gateway-server-api)
11. [Key Scripts Explained](#key-scripts-explained)
12. [Cron Jobs](#cron-jobs)
13. [Dependencies](#dependencies)

---

## Project Overview

**32GSMgateway** is a GSM-based voice and SMS broadcasting system that enables:
- **Voice Campaigns**: Automated voice calls to contacts with TTS (Text-to-Speech) name pronunciation
- **SMS Campaigns**: Bulk SMS messaging through GSM modems
- **Missed Call Services**: Missed call alerts and notifications
- **SIM Management**: Multi-SIM load balancing and automatic blocking

### Core Components:
1. **Central API Server** (Django REST API) - Manages users, campaigns, contacts, schedules
2. **Gateway Servers** - Physical servers with USB GSM modems handling actual calls/SMS
3. **Dialer Engine** - Core processing engine for call queue management

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        32GSMgateway Central Server                          │
│                         (Django + MySQL + Redis)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Users     │  │  Campaigns  │  │  Contacts   │  │ PhoneDialer │    │
│  │   Model    │  │   Model     │  │   Model     │  │   Model     │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │SmsCampaign │  │  SmsDialer  │  │SimInformation│  │MisscallMgmt│    │
│  │   Model    │  │   Model     │  │   Model     │  │   Model    │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           Core Processing Engine                            │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                    src/phone_dialer.py                               │  │
│  │   - Call queue management    - SIM load balancing                    │  │
│  │   - Threading support       - Campaign automation                    │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────────────┤
│                        Machine Status API                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                    api/views/machine_status.py                       │  │
│  │   - Django REST endpoint   - JWT authentication                     │  │
│  │   - SIM status merging    - Real-time status                        │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
           │                           │                           │
           ▼                           ▼                           ▼
    ┌─────────────┐            ┌─────────────┐            ┌─────────────┐
    │  Gateway 1  │            │  Gateway 2  │            │  Gateway N  │
    │host1.sabkiapp.com        │host2.sabkiapp.com        │hostN.sabkiapp.com
    │ ┌────┬────┐ │            │ ┌────┬────┐ │            │ ┌────┬────┐ │
    │ │SIM1│SIM2│ │            │ │SIM1│SIM2│ │            │ │SIM1│SIM2│ │
    │ │Port│Port│ │            │ │Port│Port│ │            │ │Port│Port│ │
    │ └────┴────┘ │            │ └────┴────┘ │            │ └────┴────┘ │
    └─────────────┘            └─────────────┘            └─────────────┘
```

---

## Project Structure

```
32GSMcentral/
│
├── central_ip.txt                    # Central server IP (206.189.130.26)
│
└── VoiceAPI/
    │
    ├── requirements.txt               # Python dependencies
    │
    ├── sabkiapp_google.json          # Google Cloud TTS credentials
    │
    └── voiceapi/                     # Main Django project
        │
        ├── manage.py                 # Django management script
        │
        ├── phone_dialer.py           # [VERSION 1] Simple status checker
        │
        ├── phone_dialer_old.py       # Previous version backup
        │
        ├── phone_dialer_log.txt      # Dialer logs
        │
        ├── phone_dialer_logfile.txt  # Detailed dialer logs
        │
        ├── server.log                # Django server logs
        │
        ├── nohup.out                 # Background process output
        │
        ├── machine_status_fetch_time.pkl  # Pickle cache for machine status
        │
        ├── user_status.pkl           # Pickle cache for user status
        │
        ├── voiceapi/                 # Django project settings
        │   ├── settings.py           # Django settings (DB, JWT, CORS)
        │   ├── urls.py              # URL routing
        │   ├── wsgi.py              # WSGI config
        │   ├── asgi.py              # ASGI config (WebSocket)
        │   ├── utils.py             # Utility functions
        │   ├── mytime.py            # Time utilities
        │   ├── name_pronouncer.py   # Name pronunciation logic
        │   └── api_docs.json         # API documentation
        │
        ├── api/                      # Django app
        │   ├── models/              # Database models
        │   │   ├── users.py         # Custom user model
        │   │   ├── campaign.py      # Campaign model
        │   │   ├── contacts.py      # Contacts model
        │   │   ├── dial_plan.py     # Dial plan model
        │   │   ├── voices.py        # Voice files model
        │   │   ├── sim_information.py   # SIM card info
        │   │   ├── user_hosts.py    # Gateway hosts model
        │   │   ├── sms_template.py  # SMS templates
        │   │   ├── sms_campaign.py  # SMS campaigns
        │   │   ├── sms_dialer.py   # SMS dialer queue
        │   │   ├── phone_dialer.py # Call dialer queue
        │   │   ├── call_status.py  # Call status tracking
        │   │   ├── call_info.py    # Call info records
        │   │   ├── misscalls.py    # Missed calls
        │   │   ├── misscall_management.py  # Misscall operators
        │   │   └── ...
        │   │
        │   ├── views/               # API views
        │   │   ├── machine_status.py    # ★ KEY FILE - Django REST API
        │   │   ├── campaign.py         # Campaign CRUD
        │   │   ├── contacts.py         # Contact management
        │   │   ├── authentication.py    # Login/Register
        │   │   ├── sms_campaign.py     # SMS campaigns
        │   │   ├── sms_dialer.py       # SMS sending
        │   │   ├── user_hosts.py       # Host management
        │   │   ├── misscall_management.py
        │   │   └── ...
        │   │
        │   ├── urls.py              # API routes
        │   │
        │   ├── serializers.py       # DRF serializers
        │   │
        │   └── consumers.py         # WebSocket consumers
        │
        ├── src/                    # ★ CORE PROCESSING ENGINE
        │   ├── phone_dialer.py     # ★ MAIN DIALER (Full version)
        │   ├── get_machine_status.py   # ★ Simple HTTP wrapper
        │   ├── sabkiapp_server.py  # External API integrations
        │   ├── audio_utils.py      # Audio processing
        │   ├── voice_uploader.py   # Voice file upload
        │   ├── pronunciation_gen.py # TTS pronunciation
        │   ├── sms_sender.py       # SMS sending logic
        │   ├── sms_counter.py      # SMS counting
        │   ├── phone_encrypter.py  # Phone number encryption
        │   ├── phone_dialer_status.py
        │   ├── mytime.py          # Time utilities
        │   └── Untitled-1          # Legacy file
        │
        ├── voices/                 # Uploaded audio files
        │
        └── tmp/                   # Temporary files
```

---

## Core vs Machine Status Versions - KEY DIFFERENCES

This is the MOST IMPORTANT section. There are TWO versions of critical functionality:

### 1. phone_dialer.py - Two Versions

#### Version A: `voiceapi/phone_dialer.py` (ROOT - Simple)
**Location**: `/home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi/phone_dialer.py`
**Lines**: ~68 lines
**Purpose**: Simple SIM status checker

```python
# Key characteristics:
- Only fetches machine status from gateways
- Updates SIM last_call_time
- Finds SIM with lowest call time today
- Has hardcoded check for user_id == 10000002
- No call queue processing
- No threading support
- Basic concurrent.futures for parallel status fetch
```

**Functions**:
- `get_machine_status(user_host)` - Fetch status from gateway
- `update_sim_information(host, sim_imsi)` - Update last call time
- `process_response(response_list)` - Find ready SIMs

**Use Case**: Simple monitoring, not for production dialing

---

#### Version B: `voiceapi/src/phone_dialer.py` (CORE - Full Production)
**Location**: `/home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi/src/phone_dialer.py`
**Lines**: ~587 lines
**Purpose**: Complete production dialer engine

```python
# Key characteristics:
- Full call queue management
- Threading support for parallel calls
- SIM blocking/unblocking logic
- Campaign status automation
- Status tracking (sent_status)
- Automatic retry logic
- Pickle-based caching
- User priority handling
- Blocked SIM detection
```

**Key Functions**:

| Function | Purpose |
|----------|---------|
| `get_phone_dilaer_list()` | Main queue processor |
| `make_call_thread()` | Execute actual calls |
| `process_response()` | Find ready SIMs, sort by call time |
| `get_user_host_response_thread()` | Thread per gateway |
| `update_sim_information()` | Track SIM usage |
| `update_final_call_status()` | Cleanup stale entries |
| `update_phone_dialer_and_sim_info()` | Handle blocked SIMs |

**sent_status Values**:
| Status | Meaning |
|--------|---------|
| 0 | Pending (not sent) |
| 1 | Processing/sent |
| 3 | Completed |
| 5 | Blocked (SIM blocked) |
| 6 | Reserved for specific call_through |
| 7 | Failed |

**Use Case**: Production call processing

---

### 2. get_machine_status.py - Two Versions

#### Version A: `voiceapi/src/get_machine_status.py` (Simple HTTP Wrapper)
**Location**: `/home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi/src/get_machine_status.py`
**Lines**: ~12 lines

```python
def get_machine_status(user_host):
    """Simple HTTP request wrapper"""
    try:
        response = requests.get(
            f'https://{user_host.host}.sabkiapp.com/machine_status',
            params={
                'host': user_host.host,
                'password': user_host.system_password
            },
            timeout=10
        )
        return response.json()
    except requests.exceptions.RequestException as e:
        return None
```

**Purpose**: Thin wrapper for making HTTP requests to gateway servers

---

#### Version B: `voiceapi/api/views/machine_status.py` (Django REST API)
**Location**: `/home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi/api/views/machine_status.py`
**Lines**: ~215 lines

```python
# Key characteristics:
- Django REST Framework view
- JWT authentication required
- Merges SIM info with database
- Status normalization (Ready/Busy/Waiting/Blocked)
- Daily reset logic for SIM stats
- Returns formatted JSON response
```

**Key Functions**:

| Function | Purpose |
|----------|---------|
| `get_user_id_from_token()` | Extract user from JWT |
| `merge_sim_information()` | Merge gateway data with DB |
| `fetch_machine_status()` | Main status fetcher |
| `get_all_machine_status()` | Django view endpoint |

**merge_sim_information() Logic**:
```python
1. For each port in response:
   - Get SIM IMSI
   - Look up in SimInformation table
   - If found:
     * Check today's block status
     * Reset daily stats if new day
     * Calculate final_status:
       - If time_since_last_call < 5s: "Busy"
       - If time_since_last_call < call_after: "Waiting"
       - Otherwise: "Ready"
     * Update block count if blocked
   - If not found: create default info

2. Return merged status
```

**API Endpoint**:
```
GET /get_all_machine_status?host={host}
Authorization: Bearer {jwt_token}

Response:
{
    "host": "host1",
    "machine_power_status": 1,
    "number_of_sims_ready": 4,
    "number_of_sims_busy": 1,
    "number_of_sims_blocked": 0,
    "port_data": [
        {
            "port": 1,
            "sim_imsi": "123456789012345",
            "phone_number": "+919999999999",
            "final_status": "Ready",
            "calls_made_today": 15,
            "call_time_today": 450,
            ...
        }
    ]
}
```

---

### Comparison Table

| Aspect | Root Version (phone_dialer.py) | Core Version (src/phone_dialer.py) |
|--------|-------------------------------|-------------------------------------|
| **Lines** | ~68 | ~587 |
| **Threading** | Basic ThreadPoolExecutor | Full threading with locks |
| **Queue Management** | ❌ None | ✅ Complete |
| **SIM Blocking** | ❌ None | ✅ Automatic |
| **Campaign Status** | ❌ None | ✅ Auto-complete |
| **Pickle Caching** | ❌ None | ✅ Yes |
| **Production Ready** | ❌ No | ✅ Yes |

| Aspect | src/get_machine_status.py | api/views/machine_status.py |
|--------|--------------------------|----------------------------|
| **Lines** | ~12 | ~215 |
| **Type** | Simple function | Django REST view |
| **Auth** | None | JWT required |
| **DB Merge** | ❌ None | ✅ Complete |
| **Status Logic** | Raw | Normalized |

---

## Database Models

### Core Models in Detail

#### 1. Users (`api/models/users.py`)
```python
class Users(AbstractBaseUser, PermissionsMixin):
    id = models.BigAutoField(primary_key=True)
    name = models.CharField(max_length=255, db_index=True)
    mobile_number = models.CharField(max_length=15, unique=True, db_index=True)
    password = models.CharField(max_length=255, db_index=True)
    status = models.IntegerField(db_index=True)  # 0=inactive, 1=active
    modified_at = models.DateTimeField(auto_now=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    ref_id = models.ForeignKey('self', on_delete=models.SET_NULL, null=True)
    api_key = models.CharField(max_length=255, null=True, blank=True)

    USERNAME_FIELD = 'mobile_number'
```

#### 2. Campaign (`api/models/campaign.py`)
```python
class Campaign(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    campaign_name = models.CharField(max_length=255)
    campaign_type = models.IntegerField()  # 1=voice, 2=missed call
    category = models.CharField(max_length=255)
    voice = models.ForeignKey('Voices', on_delete=models.CASCADE)
    status = models.IntegerField()  # 0=pending, 1=active, 2=paused, 3=completed
    start_date = models.DateField()
    end_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    language = models.CharField(max_length=10, null=True)
    gender = models.CharField(max_length=10, null=True)
    allow_repeat = models.IntegerField(default=1)  # Allow retries
    trials = models.IntegerField(default=0)
    campaign_priority = models.IntegerField(default=0)  # Higher = priority
    name_spell = models.IntegerField(default=0)  # Use TTS name pronunciation
    contacts_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
```

#### 3. Contacts (`api/models/contacts.py`)
```python
class Contacts(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    phone_number = models.CharField(max_length=15, db_index=True)
    name = models.CharField(max_length=255, null=True)
    category = models.CharField(max_length=255, db_index=True)
    status = models.IntegerField(default=1)  # 0=inactive, 1=active
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [['user', 'phone_number']]
```

#### 4. PhoneDialer (`api/models/phone_dialer.py`)
```python
class PhoneDialer(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    campaign = models.ForeignKey(Campaign, on_delete=models.CASCADE)
    phone_number = models.CharField(max_length=15, db_index=True)
    name = models.CharField(max_length=255, null=True)
    sent_status = models.IntegerField(db_index=True)  # See status table below
    sent_datetime = models.DateTimeField(null=True, db_index=True)
    trials = models.IntegerField(default=0)
    block_trials = models.IntegerField(default=0)
    call_through = models.CharField(max_length=15, null=True, db_index=True)  # SIM to use
    duration = models.IntegerField(default=0)

    class Meta:
        indexes = [
            models.Index(fields=['campaign', 'sent_status']),
            models.Index(fields=['sent_datetime']),
        ]
```

**sent_status Reference**:
| Value | Meaning | Description |
|-------|---------|-------------|
| 0 | Pending | Not yet processed |
| 1 | Processing | Call initiated |
| 3 | Completed | Call finished |
| 5 | Blocked | SIM blocked |
| 6 | Reserved | Reserved for call_through |
| 7 | Failed | Call failed |

#### 5. SimInformation (`api/models/sim_information.py`)
```python
class SimInformation(models.Model):
    host = models.CharField(max_length=100, db_index=True)
    sim_imsi = models.CharField(max_length=100, db_index=True)
    phone_no = models.CharField(max_length=15, blank=True, null=True)
    sms_balance = models.IntegerField(default=100)
    validity = models.DateField(null=True, blank=True)
    last_validity_check = models.DateTimeField(null=True)
    calls_made_total = models.IntegerField(default=0)
    calls_made_today = models.IntegerField(default=0)
    call_time_total = models.IntegerField(default=0)
    call_time_today = models.IntegerField(default=0)
    call_status_date = models.DateField(default='2024-01-01')
    last_call_time = models.DateTimeField(null=True)
    today_block_status = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    call_after = models.IntegerField(default=20)  # Seconds between calls

    class Meta:
        unique_together = [['host', 'sim_imsi']]
```

#### 6. UserHosts (`api/models/user_hosts.py`)
```python
class UserHosts(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    host = models.CharField(max_length=255, db_index=True)
    system_password = models.CharField(max_length=255)
    status = models.IntegerField(default=1)  # 0=inactive, 1=active
    priority = models.IntegerField(default=0)  # Higher = priority
    allow_sms = models.IntegerField(default=0)  # 0=no, 1=yes

    class Meta:
        unique_together = [['user', 'host']]
```

#### 7. SmsCampaign (`api/models/sms_campaign.py`)
```python
class SmsCampaign(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    campaign_name = models.CharField(max_length=255)
    template = models.ForeignKey('SmsTemplate', on_delete=models.CASCADE)
    status = models.IntegerField()
    start_date = models.DateField()
    end_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    created_at = models.DateTimeField(auto_now_add=True)
```

#### 8. SmsDialer (`api/models/sms_dialer.py`)
```python
class SmsDialer(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    sms_campaign = models.ForeignKey(SmsCampaign, on_delete=models.CASCADE)
    phone_number = models.CharField(max_length=15)
    sent_status = models.IntegerField()  # 0=pending, 1=sent, 2=failed
    sent_datetime = models.DateTimeField(null=True)
    sms_count = models.IntegerField(default=0)  # Characters/160 = segments
```

#### 9. MisscallManagement (`api/models/misscall_management.py`)
```python
class MisscallManagement(models.Model):
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    operator = models.CharField(max_length=255)  # Airtel, Jio, etc.
    missed_number = models.CharField(max_length=15)  # Number to miss call
    associated_number = models.CharField(max_length=15)  # Forward to
    status = models.IntegerField(default=1)
    description = models.CharField(max_length=255, null=True)
```

---

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new user |
| POST | `/sign_in` | User login (returns JWT) |
| POST | `/reset_password` | Reset password |
| POST | `/change_password` | Change password |
| POST | `/generate_api_key` | Generate API key |
| GET | `/get_api_key` | Get user's API key |

### Campaigns
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/campaigns` | List all campaigns |
| POST | `/add_campaign` | Create new campaign |
| GET | `/campaign_detail/<id>` | Get campaign details |
| POST | `/update_campaign` | Update campaign |
| POST | `/update_campaign_status` | Toggle campaign status |
| POST | `/update_campaign_audio` | Change campaign audio |
| POST | `/add_contacts_to_campaign` | Add contacts to campaign |
| DELETE | `/delete_campaign_contact` | Remove contact from campaign |
| POST | `/trigger_dialer` | Manually trigger dialer |

### Contacts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/contacts` | List contacts (paginated) |
| POST | `/add_contacts` | Add new contact |
| DELETE | `/delete_contacts` | Delete contacts |
| GET | `/get_unique_categories` | Get categories |
| POST | `/category_contacts_delete` | Delete category |
| POST | `/upload_contacts` | Bulk CSV upload |

### Audio/Voice
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/add_audio` | Upload audio file |
| GET | `/voices` | List voice files |
| POST | `/update_voice` | Update voice metadata |
| POST | `/update_audio_status` | Toggle audio status |
| GET | `/get_pronunciation` | Get TTS pronunciation |

### Dial Plan
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/add_dial_plan` | Create dial plan |
| GET | `/dial_plan/<campaign_id>` | Get campaign dial plan |
| POST | `/update_dial_plan` | Update dial plan |

### Hosts & Machine Status
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/user_host` | Add/manage host |
| GET | `/get_hosts/<user_id>` | Get user's hosts |
| POST | `/change_host_status` | Toggle host |
| POST | `/edit_host/<host_id>` | Edit host |
| GET | `/get_host_password` | Get host password |
| GET | `/get_all_machine_status` | ★ Get machine status (uses api/views/machine_status.py) |
| GET | `/sim_information` | Get SIM info |

### SMS
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/send_sms` | Send single SMS |
| POST | `/add_sms_campaign` | Create SMS campaign |
| GET | `/get_sms_campaigns` | List SMS campaigns |
| POST | `/update_sms_campaign_status` | Toggle SMS campaign |
| POST | `/add_contacts_to_sms_campaign` | Add contacts |

### Missed Calls
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/add_misscall_operator` | Add operator |
| GET | `/get_misscall_operators` | List operators |
| GET | `/view_misscalls` | View missed calls |
| GET | `/download_misscalls_report` | Export CSV |

### Reports
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/campaign_summary_report` | Campaign summary |
| GET | `/campaign_detail_report` | Campaign details |
| GET | `/download_campaign_report` | Download CSV |
| GET | `/sms_campaign_report` | SMS report |

---

## Installation & Setup

### 1. System Requirements
- Ubuntu 20.04+ / Debian 11+
- Python 3.8+
- MySQL 8.0+
- 4GB RAM minimum
- 20GB SSD storage

### 2. Install System Dependencies
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install python3 python3-pip python3-venv mysql-server nginx

# Install Python dev tools
sudo apt install python3-dev default-libmysqlclient-dev build-essential
```

### 3. Create Project Directory
```bash
mkdir -p /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI
cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI
```

### 4. Set Up Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### 5. Install Python Dependencies
```bash
pip install -r requirements.txt
```

Or install manually:
```bash
pip install Django==4.2.6
pip install djangorestframework==3.14.0
pip install djangorestframework-simplejwt==5.3.0
pip install djoser==2.2.0
pip install django-cors-headers==4.3.1
pip install mysqlclient==2.2.0
pip install PyMySQL==1.1.0
pip install requests==2.31.0
pip install google-cloud-texttospeech==2.16.1
pip install gTTS==2.5.1
pip install phonenumbers==8.13.29
pip install channels==4.0.0
pip install gevent==23.9.1
```

### 6. Create Database
```bash
sudo mysql -u root -p

# In MySQL shell:
CREATE DATABASE sabkiapp_asterisk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'sabkiapp_asterisk'@'localhost' IDENTIFIED BY '@O5[mxJD_k3bsAAk';
GRANT ALL PRIVILEGES ON sabkiapp_asterisk.* TO 'sabkiapp_asterisk'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 7. Configure Settings
Edit `voiceapi/voiceapi/settings.py`:

```python
# Database Configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'sabkiapp_asterisk',
        'USER': 'sabkiapp_asterisk',
        'PASSWORD': '@O5[mxJD_k3bsAAk',
        'HOST': '139.59.85.92',  # Or localhost
        'PORT': '3306',
    }
}

# Allowed Hosts
ALLOWED_HOSTS = ['call.sabkiapp.com', 'localhost', '127.0.0.1']

# JWT Settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=14400),  # 10 days
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
}
```

### 8. Run Migrations
```bash
cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi
python manage.py makemigrations
python manage.py migrate
```

### 9. Create Superuser
```bash
python manage.py createsuperuser
```

---

## Configuration

### Django Settings (voiceapi/voiceapi/settings.py)

```python
# Security
SECRET_KEY = "ureq!b3k^jw6p@5b*%0gb@xbm1b8v232(*7wnv*&e)q#49y3re"
DEBUG = True  # False in production
ALLOWED_HOSTS = ['*']  # Configure for production

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'sabkiapp_asterisk',
        'USER': 'sabkiapp_asterisk',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}

# REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.AllowAny',  # Change to IsAuthenticated for production
    ),
}

# JWT
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=14400),
    'ROTATE_REFRESH_TOKENS': False,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# CORS
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# Application Definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'djoser',
    'api',
    'channels',
    'corsheaders',
]

# Channel Layers (for WebSocket)
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer',
    },
}

# Custom Settings
API_KEY_CRONJOB = "dklasjeiopduqw4iohjh480ehhcdjh3u8092"
API_KEY_RETURN_MISS_CALL = "3d2f4b8f9a1c7e6d"
PHONE_ENCRYPTER_KEY = "DDIjoS0ckWyXJHexm6OYdK8XZy8p9YDo"
sabkiapp_password = "3789yduiahy3"
sabkiapp_base_url = "https://bankjaal.com/v2"
sabkiapp_misscall_password = "kranti2024"
```

### Environment Variables (.env)
```bash
# Create .env file
DJANGO_SECRET_KEY=ureq!b3k^jw6p@5b*%0gb@xbm1b8v232(*7wnv*&e)q#49y3re
DATABASE_NAME=sabkiapp_asterisk
DATABASE_USER=sabkiapp_asterisk
DATABASE_PASSWORD=@O5[mxJD_k3bsAAk
DATABASE_HOST=139.59.85.92
DEBUG=True
ALLOWED_HOSTS=*
```

---

## Running the System

### 1. Start Django Server (API)
```bash
cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi
python manage.py runserver 0.0.0.0:8000
```

### 2. Start Phone Dialer (Core Engine)
```bash
# Method 1: Direct run (for testing)
cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi
python src/phone_dialer.py

# Method 2: Background process (production)
nohup python src/phone_dialer.py > /var/log/phone_dialer.log 2>&1 &

# Method 3: Cron job (every minute)
crontab -e
# Add: * * * * * cd /path/to/voiceapi && python src/phone_dialer.py >> /var/log/dialer.log 2>&1
```

### 3. Production with Gunicorn
```bash
# Install gunicorn
pip install gunicorn

# Run with gunicorn
cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi
gunicorn voiceapi.wsgi:application --bind 0.0.0.0:8000 --workers 4 --timeout 120
```

### 4. Verify Running Services
```bash
# Check Django
curl http://localhost:8000/

# Check machine status endpoint
curl -H "Authorization: Bearer <token>" http://localhost:8000/get_all_machine_status?host=host1

# Check dialer logs
tail -f phone_dialer_log.txt
```

---

## Gateway Server API

Each gateway machine must run a web server exposing these endpoints:

### 1. Machine Status
```
GET https://{host}.sabkiapp.com/machine_status?host={host}&password={password}

Response:
{
    "host": "host1",
    "machine_power_status": 1,
    "number_of_sims_ready": 4,
    "number_of_sims_busy": 1,
    "number_of_sims_blocked": 0,
    "total_sms_balance": 500,
    "port_data": [
        {
            "port": 1,
            "sim_imsi": "123456789012345",
            "phone_number": "+919999999999",
            "signal": "Good",
            "network": "4G",
            "final_status": "Ready",
            "call_time_today": 450,
            "calls_made_today": 15
        }
    ]
}
```

### 2. Make Call
```
POST https://{host}.sabkiapp.com/make_call
Content-Type: application/json

{
    "host": "host1",
    "system_password": "password",
    "phone_number": "919999999999",
    "port": 1,
    "user_id": 1,
    "campaign_id": 1,
    "name": "John",
    "name_spell": 1
}

Response:
{
    "status": "success",
    "call_id": "12345"
}
```

### 3. Send SMS
```
POST https://{host}.sabkiapp.com/send_sms
Content-Type: application/json

{
    "host": "host1",
    "password": "password",
    "phone_number": "919999999999",
    "message": "Hello!",
    "port": 1
}

Response:
[
    [
        {"sms_dialer_id": 1},
        200
    ]
]
```

---

## Key Scripts Explained

### src/phone_dialer.py (Core Dialer)
The main production dialer that:
1. Fetches active campaigns
2. Finds active hosts with ready SIMs
3. Matches contacts to SIMs using load balancing
4. Triggers calls via gateway API
5. Updates call status in database
6. Handles SIM blocking

### src/get_machine_status.py
Simple HTTP wrapper used by core dialer to fetch gateway status.

### api/views/machine_status.py
Django REST API that:
- Authenticates requests via JWT
- Fetches machine status
- Merges with database records
- Normalizes SIM status
- Returns formatted JSON

### src/sabkiapp_server.py
External API integrations:
- `get_name()` - Fetch contact names from database or external API
- `get_user_id()` - Get user ID from phone number
- `store_misscall_on_sabkiapp()` - Log missed calls

### src/sms_sender.py
SMS sending class:
- Sends SMS via gateway API
- Updates status in database
- Handles retry logic

---

## Cron Jobs

Add these to your crontab for production:

```bash
# Phone dialer - runs every minute
* * * * * cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi && python src/phone_dialer.py >> /var/log/dialer.log 2>&1

# Update call status - runs every 5 minutes
*/5 * * * * cd /home/ubuntu/Documents/projects/32GSMcentral/VoiceAPI/voiceapi && python -c "
import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'voiceapi.settings')
django.setup()
from src.phone_dialer import update_final_call_status
update_final_call_status()
" >> /var/log/status_update.log 2>&1
```

---

## Dependencies

### Core Dependencies
```
Django==4.2.6
djangorestframework==3.14.0
djangorestframework-simplejwt==5.3.0
djoser==2.2.0
django-cors-headers==4.3.1
channels==4.0.0
```

### Database
```
mysqlclient==2.2.0
PyMySQL==1.1.0
mysql-connector-python==8.1.0
```

### External APIs
```
requests==2.31.0
google-cloud-texttospeech==2.16.1
gTTS==2.5.1
phonenumbers==8.13.29
```

### Utilities
```
python-dateutil==2.8.2
pytz==2023.3.post1
```

---

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check MySQL is running: `sudo systemctl status mysql`
   - Verify credentials in settings.py
   - Check firewall rules for port 3306

2. **Machine Status Not Responding**
   - Verify gateway server is running
   - Check network connectivity
   - Verify credentials match in UserHosts

3. **Calls Not Initiating**
   - Check SIM status in SimInformation
   - Verify campaign dates/times are valid
   - Check dialer logs for errors

4. **JWT Token Issues**
   - Clear browser cache
   - Regenerate API key
   - Check JWT settings in settings.py

---

*Documentation generated: March 2026*
*Project: 32GSMgateway*
