import 'package:kempa/core/network/api_client.dart';
import 'package:kempa/features/academic/data/models/auditory_model.dart';
import 'package:kempa/features/academic/data/models/faculty_model.dart';
import 'package:kempa/features/academic/data/models/group_model.dart';
import 'package:kempa/features/academic/data/models/teacher_model.dart';

abstract class AcademicRemoteDatasource {
  Future<List<FacultyModel>> getFaculties();
  Future<List<GroupModel>> getGroups(int facultyId);
  Future<List<AuditoryModel>> getAuditories();
  Future<List<TeacherModel>> getTeachers();
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
  
  @override
  Future<List<AuditoryModel>> getAuditories() async {
    final response = await _client.get("/schedule/integration/scheduleAuditorList");
    final data = response.data as Map<String, dynamic>;

    if(data['success'] != true){
      throw Exception(data['message'] ?? 'Failed to load auditories');
    }

    final List<dynamic> result = data['auditorList'];

    return result
        .map((json) => AuditoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  @override
  Future<List<TeacherModel>> getTeachers() async {
    final response = await _client.get("/schedule/integration/teacherList");
    final data = response.data as Map<String, dynamic>;

    if(data['success'] != true){
      throw Exception(data['message'] ?? 'Failed to load teachers');
    }

    final List<dynamic> result = data['teacherList'];

    return result
        .map((json) => TeacherModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}