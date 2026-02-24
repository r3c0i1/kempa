import 'package:kempa/core/network/api_client.dart';
import 'package:kempa/features/academic/data/models/faculty_model.dart';
import 'package:kempa/features/academic/data/models/group_model.dart';

abstract class AcademicRemoteDatasource {
  Future<List<FacultyModel>> getFaculties();
  Future<List<GroupModel>> getGroups(int facultyId);
}

class AcademicRemoteDatasourceImpl implements AcademicRemoteDatasource {
  
  final ApiClient _client;

  AcademicRemoteDatasourceImpl(this._client);
  
  @override
  Future<List<FacultyModel>> getFaculties() async {
    final response = await _client.get("/schedule/integration/facultyList");
    final data = response.data as Map<String, dynamic>;

    if(data['success'] != true){
      throw Exception(data['message'] ?? 'Failed to load faculties');
    }

    final List<dynamic> result = data['result'];

    return result
        .map((json) => FacultyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  @override
  Future<List<GroupModel>> getGroups(int facultyId) async {
    final response = await _client.get("/schedule/integration/groupList", queryParameters: {
      "facultyId": facultyId
    });
    final data = response.data as Map<String, dynamic>;

    if(data['success'] != true){
      throw Exception(data['message'] ?? 'Failed to load groups');
    }

    final List<dynamic> result = data['result'];

    return result
        .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}