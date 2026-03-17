/// Name of Application
const kAppName = "SabkiApp DigiCamp";

/// AppRoutes
enum AppRoutes {
  dashboard(name: 'Dashboard', path: '/dashboard'),
  // Campaigns
  addCampaign(name: 'Add Campaign', path: '/add-campaign'),
  updateCampaign(name: 'Update Campaign', path: '/update-campaign'),
  viewCampaigns(name: 'View Campaign', path: '/view-campaigns'),
  selectCampaign(name: 'Select Campaign', path: '/select-campaign'),
  dialPlan(name: 'Dial Plan', path: '/dial-plan/:campaignId'),
  campaignReport(name: 'Campaign Report', path: '/campaign-report/:campaignId'),
  campaignSummary(
    name: 'Campaign Summary',
    path: '/campaign-summary/:campaignId',
  ),

  // Auth
  signIn(name: 'Sign In', path: '/sign-in'),

  // Audios
  addAudio(name: 'Add Audio', path: '/add-audio'),
  viewAudios(name: 'View Audios', path: '/view-audios'),
  selectAudio(name: 'Select Audio', path: '/select-audio'),

  // Contacts
  addContacts(name: 'Add Contacts', path: '/add-contacts'),
  viewContacts(name: 'View Contacts', path: '/view-contacts'),

  // SMS
  addSms(name: 'Add SMS', path: '/add-sms'),
  editSms(name: 'Edit SMS', path: '/edit-sms'),
  viewSms(name: 'View SMS', path: '/view-sms'),
  selectSms(name: 'Select SMS', path: '/select-sms'),
  addBulkSms(name: 'Send Bulk Sms', path: '/add-bulk-sms'),
  updateBulkSms(name: 'Update Bulk SMS', path: '/update-bulk-sms'),
  viewBulkSms(name: 'View Bulk Sms', path: '/view-bulk-sms'),

  // Users
  users(name: 'Users', path: '/users'),
  userHosts(name: 'User Hosts', path: '/users-hosts/:userId'),
  apiList(name: 'Api List', path: '/api-list'),

  // Miss call management
  addOperator(name: 'Add Operator', path: '/add-operator'),
  viewMissCall(name: 'View Miss Call', path: '/view-miss-call'),
  allOperators(name: 'All Operators', path: '/all-operators');

  final String name;
  final String path;

  const AppRoutes({required this.name, required this.path});
}

/// Hive boxes
const kSettingBox = "settingBox";
const kAuthBox = "authBox";
