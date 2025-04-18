
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/colors.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/submission_entity.dart';
import '../providers/assignment_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../routes/app_routes.dart';

/// Screen for viewing an assignment's details
class AssignmentScreen extends StatefulWidget {
  /// ID of the group containing the assignment
  final String groupId;
  
  /// ID of the assignment to display
  final String assignmentId;
  
  /// Creates an AssignmentScreen
  const AssignmentScreen({
    Key? key,
    required this.groupId,
    required this.assignmentId,
  }) : super(key: key);

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final assignmentProvider = Provider.of<AssignmentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load assignment details
      await assignmentProvider.loadAssignment(
        widget.groupId,
        widget.assignmentId,
      );
      
      // Load student's submission if the user is a student
      if (authProvider.user != null && authProvider.user!.isStudent) {
        await assignmentProvider.loadStudentSubmission(
          widget.groupId,
          widget.assignmentId,
          authProvider.user!.id,
        );
      }
      
      // Load all submissions if the user is a lecturer
      if (authProvider.user != null && 
          (authProvider.user!.isLecturer || authProvider.user!.isClassRep)) {
        await assignmentProvider.loadSubmissions(
          widget.groupId,
          widget.assignmentId,
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading assignment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final assignment = assignmentProvider.currentAssignment;
    final studentSubmission = assignmentProvider.studentSubmission;
    final user = authProvider.user;
    
    final bool canEdit = user != null && 
                         assignment != null && 
                         (user.isLecturer || user.isClassRep || user.id == assignment.creatorId);
    
    final bool canViewSubmissions = user != null && 
                                  (user.isLecturer || user.isClassRep);
    
    final bool canSubmit = user != null && 
                          user.isStudent && 
                          assignment != null && 
                          !assignment.isOverdue;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
        actions: [
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).pushNamed(
                    AppRoutes.editAssignment,
                    arguments: {
                      'groupId': widget.groupId,
                      'assignmentId': widget.assignmentId,
                    },
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Assignment'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Assignment', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : assignment == null
              ? const Center(
                  child: Text('Assignment not found'),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Assignment title and status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                assignment.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusBadge(assignment),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Assignment details
                        _buildInfoRow(
                          'Due Date',
                          DateFormat('EEE, MMM d, yyyy').format(assignment.dueDate),
                          Icons.calendar_today,
                        ),
                        if (assignment.points != null)
                          _buildInfoRow(
                            'Points',
                            '${assignment.points} points',
                            Icons.star_outline,
                          ),
                        _buildInfoRow(
                          'Created',
                          assignment.createdAt != null
                              ? timeago.format(assignment.createdAt!)
                              : 'Unknown',
                          Icons.access_time,
                        ),
                        const SizedBox(height: 24),
                        
                        // Assignment description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            assignment.description,
                            style: TextStyle(
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Attachments
                        if (assignment.hasAttachments) ...[
                          const Text(
                            'Attachments',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAttachmentsList(assignment.attachments),
                          const SizedBox(height: 24),
                        ],
                        
                        // Student's submission
                        if (user?.isStudent == true) ...[
                          if (studentSubmission != null) ...[
                            _buildSubmissionCard(studentSubmission),
                          ] else if (canSubmit) ...[
                            const Text(
                              'Your Submission',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSubmitPrompt(),
                          ],
                        ],
                        
                        // Submissions overview (for lecturers and class reps)
                        if (canViewSubmissions) ...[
                          const SizedBox(height: 24),
                          _buildSubmissionsOverview(
                            assignmentProvider.submissions,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
      floatingActionButton: canSubmit && studentSubmission == null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.submitAssignment,
                  arguments: {
                    'groupId': widget.groupId,
                    'assignmentId': widget.assignmentId,
                  },
                );
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Submit Assignment'),
              backgroundColor: AppColors.primary,
            )
          : canViewSubmissions
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.assignmentSubmissions,
                      arguments: {
                        'groupId': widget.groupId,
                        'assignmentId': widget.assignmentId,
                      },
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('View All Submissions'),
                  backgroundColor: AppColors.primary,
                )
              : null,
    );
  }
  
  Widget _buildStatusBadge(AssignmentEntity assignment) {
    Color badgeColor;
    String statusText;
    
    if (assignment.isOverdue) {
      badgeColor = Colors.red;
      statusText = 'Overdue';
    } else if (assignment.isDueSoon) {
      badgeColor = Colors.orange;
      statusText = 'Due Soon';
    } else {
      badgeColor = Colors.green;
      statusText = 'Upcoming';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttachmentsList(List<String> attachments) {
    return Column(
      children: attachments.map((url) {
        final fileName = url.split('/').last;
        final fileExtension = fileName.split('.').last.toLowerCase();
        
        IconData fileIcon;
        Color iconColor;
        
        switch (fileExtension) {
          case 'pdf':
            fileIcon = Icons.picture_as_pdf;
            iconColor = Colors.red;
            break;
          case 'doc':
          case 'docx':
            fileIcon = Icons.description;
            iconColor = Colors.blue;
            break;
          case 'xls':
          case 'xlsx':
            fileIcon = Icons.table_chart;
            iconColor = Colors.green;
            break;
          case 'jpg':
          case 'jpeg':
          case 'png':
            fileIcon = Icons.image;
            iconColor = Colors.purple;
            break;
          default:
            fileIcon = Icons.insert_drive_file;
            iconColor = Colors.grey;
        }
        
        return ListTile(
          leading: Icon(
            fileIcon,
            color: iconColor,
          ),
          title: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.download),
          onTap: () {
            // Open or download the attachment
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildSubmissionCard(SubmissionEntity submission) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Submission',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: submission.isGraded
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: submission.isGraded ? Colors.green : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    submission.isGraded ? 'Graded' : 'Submitted',
                    style: TextStyle(
                      color: submission.isGraded ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Submission date
            _buildInfoRow(
              'Submitted',
              DateFormat('EEE, MMM d, yyyy • h:mm a').format(submission.submittedAt),
              Icons.calendar_today,
            ),
            
            // Grade and feedback if graded
            if (submission.isGraded) ...[
              _buildInfoRow(
                'Grade',
                '${submission.grade} points',
                Icons.grade,
              ),
              const SizedBox(height: 16),
              const Text(
                'Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  submission.feedback ?? 'No feedback provided.',
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
            
            // Comment
            const SizedBox(height: 16),
            const Text(
              'Your Comment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                submission.comment,
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
            ),
            
            // Attachments if any
            if (submission.hasAttachments) ...[
              const SizedBox(height: 16),
              const Text(
                'Your Attachments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              _buildAttachmentsList(submission.attachments),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubmitPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.upload_file,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'You haven\'t submitted this assignment yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Click the Submit button below to upload your work',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubmissionsOverview(List<SubmissionEntity> submissions) {
    final total = Provider.of<AssignmentProvider>(context).currentAssignment?.memberCount ?? 0;
    final submitted = submissions.length;
    final graded = submissions.where((s) => s.isGraded).length;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submissions Overview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: total > 0 ? submitted / total : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '$submitted/$total',
                  'Submitted',
                  Icons.assignment_turned_in,
                  Colors.blue,
                ),
                _buildStatItem(
                  '$graded/$submitted',
                  'Graded',
                  Icons.grading,
                  Colors.green,
                ),
                _buildStatItem(
                  '${total - submitted}',
                  'Missing',
                  Icons.assignment_late,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment?'),
        content: const Text(
          'This action cannot be undone. All student submissions will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final assignmentProvider = Provider.of<AssignmentProvider>(
                context,
                listen: false,
              );
              
              final success = await assignmentProvider.deleteAssignment(
                widget.groupId,
                widget.assignmentId,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(); // Go back to previous screen
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
