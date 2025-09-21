import 'User.dart';
import 'Department.dart';

class UserDepartmentBinding {
  final int id;
  final int userId;
  final int departmentId;
  final User? user;
  final Department? department;

  UserDepartmentBinding({
    required this.id,
    required this.userId,
    required this.departmentId,
    this.user,
    this.department,
  });

  factory UserDepartmentBinding.fromJson(Map<String, dynamic> json) {
    return UserDepartmentBinding(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      department: json['department'] != null ? Department.fromJson(json['department']) : null,
    );
  }

  Map<String, dynamic> toJsonForSave() {
    return {
      'user_id': userId,
      'department_id': departmentId,
    };
  }
}