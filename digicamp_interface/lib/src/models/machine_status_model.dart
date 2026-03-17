class MachineStatusModel {
  String? host;
  int? machinePowerStatus;
  int? numberOfPortsWithNoSim;
  int? numberOfPortsWithNoSignal;
  int? numberOfNewSims;
  int? numberOfSimsWithNoRecharge;
  int? numberOfSimsReady;
  int? numberOfSimsBusy;
  int? totalSmsBalance;
  int? numberOfSimsBlocked;
  int? numberOfSimsWaiting;
  List<PortDataModel> portData = [];

  MachineStatusModel({
    this.host,
    this.machinePowerStatus,
    this.numberOfPortsWithNoSim,
    this.numberOfPortsWithNoSignal,
    this.numberOfNewSims,
    this.numberOfSimsWithNoRecharge,
    this.numberOfSimsReady,
    this.numberOfSimsBusy,
    this.totalSmsBalance,
    this.numberOfSimsBlocked,
    this.numberOfSimsWaiting,
    this.portData = const [],
  });

  factory MachineStatusModel.fromJson(Map<String, dynamic> json) {
    return MachineStatusModel(
      host: json['host'] as String?,
      machinePowerStatus: json['machine_power_status'] as int?,
      numberOfPortsWithNoSim: json['number_of_ports_with_no_sim'] as int?,
      numberOfPortsWithNoSignal: json['number_of_ports_with_no_signal'] as int?,
      numberOfNewSims: json['number_of_new_sims'] as int?,
      numberOfSimsWithNoRecharge:
          json['number_of_sims_with_no_recharge'] as int?,
      numberOfSimsReady: json['number_of_sims_ready'] as int?,
      numberOfSimsBusy: json['number_of_sims_busy'] as int?,
      totalSmsBalance: json['total_sms_balance'] as int?,
      numberOfSimsBlocked: json['number_of_sims_blocked'] as int?,
      numberOfSimsWaiting: json['number_of_sims_waiting'] as int?,
      portData: (json['port_data'] as List<dynamic>?)
              ?.map((e) => PortDataModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static List<MachineStatusModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<MachineStatusModel>.from(
      json.map((v) => MachineStatusModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'host': host,
        'machine_power_status': machinePowerStatus,
        'number_of_ports_with_no_sim': numberOfPortsWithNoSim,
        'number_of_ports_with_no_signal': numberOfPortsWithNoSignal,
        'number_of_new_sims': numberOfNewSims,
        'number_of_sims_with_no_recharge': numberOfSimsWithNoRecharge,
        'number_of_sims_ready': numberOfSimsReady,
        'number_of_sims_busy': numberOfSimsBusy,
        'total_sms_balance': totalSmsBalance,
        'number_of_sims_blocked': numberOfSimsBlocked,
        'number_of_sims_waiting': numberOfSimsWaiting,
        'port_data': portData.map((e) => e.toJson()).toList(),
      };
}

class PortDataModel {
  int? port;
  String? status;
  String? operator;
  String? signal;
  String? simImsi;
  String? state;
  String? phoneNumber;
  String? smsBackupDate;
  int? smsBalance;
  String? validity;
  String? lastValidityCheck;
  String? finalStatus;
  int? id;
  String? host;
  String? phoneNo;
  int? callsMadeTotal;
  int? callsMadeToday;
  int? callTimeTotal;
  int? callTimeToday;
  String? callStatusDate;
  String? lastCallTime;
  String? todayBlockStatus;
  int? callAfter;

  PortDataModel({
    this.port,
    this.status,
    this.operator,
    this.signal,
    this.simImsi,
    this.state,
    this.phoneNumber,
    this.smsBackupDate,
    this.smsBalance,
    this.validity,
    this.lastValidityCheck,
    this.finalStatus,
    this.id,
    this.host,
    this.phoneNo,
    this.callsMadeTotal,
    this.callsMadeToday,
    this.callTimeTotal,
    this.callTimeToday,
    this.callStatusDate,
    this.lastCallTime,
    this.todayBlockStatus,
    this.callAfter,
  });

  factory PortDataModel.fromJson(Map<String, dynamic> json) => PortDataModel(
        port: json['port'] as int?,
        status: json['status'] as String?,
        operator: json['operator'] as String?,
        signal: json['signal'] as String?,
        simImsi: json['sim_imsi'] as String?,
        state: json['state'] as String?,
        phoneNumber: json['phone_number'] as String?,
        smsBackupDate: json['sms_backup_date'] as String?,
        smsBalance: json['sms_balance'] as int?,
        validity: json['validity'] as String?,
        lastValidityCheck: json['last_validity_check'] as String?,
        finalStatus: json['final_status'] as String?,
        id: json['id'] as int?,
        host: json['host'] as String?,
        phoneNo: json['phone_no'] as String?,
        callsMadeTotal: json['calls_made_total'] as int?,
        callsMadeToday: json['calls_made_today'] as int?,
        callTimeTotal: json['call_time_total'] as int?,
        callTimeToday: json['call_time_today'] as int?,
        callStatusDate: json['call_status_date'] as String?,
        lastCallTime: json['last_call_time'] as String?,
        todayBlockStatus: json['today_block_status'] as String?,
        callAfter: json['call_after'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'port': port,
        'status': status,
        'operator': operator,
        'signal': signal,
        'sim_imsi': simImsi,
        'state': state,
        'phone_number': phoneNumber,
        'sms_backup_date': smsBackupDate,
        'sms_balance': smsBalance,
        'validity': validity,
        'last_validity_check': lastValidityCheck,
        'final_status': finalStatus,
        'id': id,
        'host': host,
        'phone_no': phoneNo,
        'calls_made_total': callsMadeTotal,
        'calls_made_today': callsMadeToday,
        'call_time_total': callTimeTotal,
        'call_time_today': callTimeToday,
        'call_status_date': callStatusDate,
        'last_call_time': lastCallTime,
        'today_block_status': todayBlockStatus,
        'call_after': callAfter,
      };
}
