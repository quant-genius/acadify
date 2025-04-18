
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/assignment_repository.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/submission_entity.dart';
import '../../domain/use_cases/get_assignments_use_case.dart';
import '../../domain/use_cases/create_assignment_use_case.dart';
import '../../domain/use_cases/update_assignment_use_case.dart';
import '../../domain/use_cases/delete_assignment_use_case.dart';
import '../../domain/use_cases/submit_assignment_use_case.dart';
import '../../domain/use_cases/grade_submission_use_case.dart';
import '../../domain/use_cases/get_submissions_use_case.dart';

/// Provider state for assignments
enum AssignmentState {
  /// Initial state
  initial,
  
  /// Loading state
  loading,
  
  /// Loaded state - data is available
  loaded,
  
  /// Error state - operation failed
  error,
}

/// Provider for assignment operations
class AssignmentProvider extends ChangeNotifier {
  late final AssignmentRepository _assignmentRepository;
  late final GetAssignmentsUseCase _getAssignmentsUseCase;
  late final CreateAssignmentUseCase _createAssignmentUseCase;
  late final UpdateAssignmentUseCase _updateAssignmentUseCase;
  late final DeleteAssignmentUseCase _deleteAssignmentUseCase;
  late final SubmitAssignmentUseCase _submitAssignmentUseCase;
  late final GradeSubmissionUseCase _gradeSubmissionUseCase;
  late final GetSubmissionsUseCase _getSubmissionsUseCase;
  
  /// Current assignment state
  AssignmentState _state = AssignmentState.initial;
  
  /// List of assignments
  List<AssignmentEntity> _assignments = [];
  
  /// Current assignment being viewed
  AssignmentEntity? _currentAssignment;
  
  /// List of submissions for the current assignment
  List<SubmissionEntity> _submissions = [];
  
  /// Current student's submission for the current assignment
  SubmissionEntity? _studentSubmission;
  
  /// Error message, if any
  String? _errorMessage;
  
  /// Constructor
  AssignmentProvider() {
    _initializeRepositories();
  }
  
  /// Initializes repositories and use cases
  void _initializeRepositories() {
    _assignmentRepository = AssignmentRepository();
    
    _getAssignmentsUseCase = GetAssignmentsUseCase(_assignmentRepository);
    _createAssignmentUseCase = CreateAssignmentUseCase(_assignmentRepository);
    _updateAssignmentUseCase = UpdateAssignmentUseCase(_assignmentRepository);
    _deleteAssignmentUseCase = DeleteAssignmentUseCase(_assignmentRepository);
    _submitAssignmentUseCase = SubmitAssignmentUseCase(_assignmentRepository);
    _gradeSubmissionUseCase = GradeSubmissionUseCase(_assignmentRepository);
    _getSubmissionsUseCase = GetSubmissionsUseCase(_assignmentRepository);
  }
  
  /// Loads assignments for a group
  Future<void> loadAssignments(String groupId) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _assignments = await _getAssignmentsUseCase(groupId);
      _state = AssignmentState.loaded;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Loads active assignments for a group
  Future<void> loadActiveAssignments(String groupId) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _assignments = await _getAssignmentsUseCase.getActiveAssignments(groupId);
      _state = AssignmentState.loaded;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Creates a new assignment
  Future<AssignmentEntity?> createAssignment({
    required String groupId,
    required String creatorId,
    required String title,
    required String description,
    required DateTime dueDate,
    int? points,
    List<File>? attachmentFiles,
  }) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final assignment = await _createAssignmentUseCase(
        groupId: groupId,
        creatorId: creatorId,
        title: title,
        description: description,
        dueDate: dueDate,
        points: points,
        attachmentFiles: attachmentFiles,
      );
      
      // Refresh assignments list
      await loadAssignments(groupId);
      
      return assignment;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Updates an existing assignment
  Future<AssignmentEntity?> updateAssignment({
    required String groupId,
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? points,
    List<String>? attachmentsToRemove,
    List<File>? attachmentsToAdd,
    bool? isActive,
  }) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final assignment = await _updateAssignmentUseCase(
        groupId: groupId,
        assignmentId: assignmentId,
        title: title,
        description: description,
        dueDate: dueDate,
        points: points,
        attachmentsToRemove: attachmentsToRemove,
        attachmentsToAdd: attachmentsToAdd,
        isActive: isActive,
      );
      
      // If this is the current assignment, update it
      if (_currentAssignment != null && _currentAssignment!.id == assignmentId) {
        _currentAssignment = assignment;
      }
      
      // Refresh assignments list
      await loadAssignments(groupId);
      
      return assignment;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Deletes an assignment
  Future<bool> deleteAssignment(String groupId, String assignmentId) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _deleteAssignmentUseCase(groupId, assignmentId);
      
      // Clear current assignment if it was the one deleted
      if (_currentAssignment != null && _currentAssignment!.id == assignmentId) {
        _currentAssignment = null;
      }
      
      // Refresh assignments list
      await loadAssignments(groupId);
      
      return true;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Loads a single assignment
  Future<void> loadAssignment(String groupId, String assignmentId) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _currentAssignment = await _getAssignmentsUseCase.getAssignment(
        groupId,
        assignmentId,
      );
      _state = AssignmentState.loaded;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Submits an assignment
  Future<SubmissionEntity?> submitAssignment({
    required String groupId,
    required String assignmentId,
    required String studentId,
    required String comment,
    List<File>? attachmentFiles,
  }) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final submission = await _submitAssignmentUseCase(
        groupId: groupId,
        assignmentId: assignmentId,
        studentId: studentId,
        comment: comment,
        attachmentFiles: attachmentFiles,
      );
      
      // Update student submission
      _studentSubmission = submission;
      _state = AssignmentState.loaded;
      notifyListeners();
      
      return submission;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Grades a submission
  Future<SubmissionEntity?> gradeSubmission({
    required String groupId,
    required String assignmentId,
    required String submissionId,
    required int grade,
    required String feedback,
    required String gradedBy,
  }) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final submission = await _gradeSubmissionUseCase(
        groupId: groupId,
        assignmentId: assignmentId,
        submissionId: submissionId,
        grade: grade,
        feedback: feedback,
        gradedBy: gradedBy,
      );
      
      // Refresh submissions list
      await loadSubmissions(groupId, assignmentId);
      
      return submission;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Loads submissions for an assignment
  Future<void> loadSubmissions(String groupId, String assignmentId) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _submissions = await _getSubmissionsUseCase(groupId, assignmentId);
      _state = AssignmentState.loaded;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Loads the current student's submission for an assignment
  Future<void> loadStudentSubmission(
    String groupId,
    String assignmentId,
    String studentId,
  ) async {
    _state = AssignmentState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _studentSubmission = await _submitAssignmentUseCase.getStudentSubmission(
        groupId,
        assignmentId,
        studentId,
      );
      _state = AssignmentState.loaded;
    } catch (e) {
      _state = AssignmentState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Current assignment state
  AssignmentState get state => _state;
  
  /// List of assignments
  List<AssignmentEntity> get assignments => _assignments;
  
  /// Current assignment being viewed
  AssignmentEntity? get currentAssignment => _currentAssignment;
  
  /// List of submissions for the current assignment
  List<SubmissionEntity> get submissions => _submissions;
  
  /// Current student's submission for the current assignment
  SubmissionEntity? get studentSubmission => _studentSubmission;
  
  /// Error message, if any
  String? get errorMessage => _errorMessage;
  
  /// Returns true if assignments are being loaded
  bool get isLoading => _state == AssignmentState.loading;
  
  /// Returns true if there was an error
  bool get hasError => _state == AssignmentState.error;
  
  /// Returns assignments sorted by due date (closest first)
  List<AssignmentEntity> get upcomingAssignments {
    final now = DateTime.now();
    return List.from(_assignments)
      ..retainWhere((a) => a.dueDate.isAfter(now))
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  /// Returns overdue assignments
  List<AssignmentEntity> get overdueAssignments {
    final now = DateTime.now();
    return List.from(_assignments)
      ..retainWhere((a) => a.dueDate.isBefore(now))
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }
}
