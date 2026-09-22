import 'package:senai_checkin/model/user_logs.dart';
import 'package:senai_checkin/service/db_helper.dart';

class LogsController {
  Future<List<UserLogs>> getLogs() async {
    return await DbHelper().getLogs();
  }

  Future<int> postLogs(UserLogs u) async {
    return await DbHelper().postLogs(u);
  }
}