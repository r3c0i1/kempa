import 'package:dio/dio.dart';
import 'package:kempa/core/network/api_client.dart';
import 'package:kempa/features/schedule/data/models/day_info_model.dart';

abstract class ScheduleRemoteDatasource {
  Future<DayInfoModel> getDayInfo();
}

class ScheduleRemoteDatasourceImpl implements ScheduleRemoteDatasource {

  final ApiClient client;

  ScheduleRemoteDatasourceImpl(this.client);

  @override
  Future<DayInfoModel> getDayInfo() async {
    try {
      final response = await client.get(
        '/schedule/integration/currentDayInfo',
      );
      return DayInfoModel.fromJson(response.data['currentDay']);
    } on DioException catch (e) {
      switch (e.response?.statusCode){
        default:
          rethrow;
      }
    }
  }

}