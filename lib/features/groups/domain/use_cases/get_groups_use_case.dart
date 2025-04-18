
import '../../data/repositories/group_repository.dart';
import '../entities/group_entity.dart';

/// Use case for getting all groups for a user
class GetGroupsUseCase {
  final GroupRepository _groupRepository;
  
  /// Constructor that takes GroupRepository
  GetGroupsUseCase(this._groupRepository);
  
  /// Executes the get groups operation
  ///
  /// [userId] - The ID of the user to get groups for
  /// Returns a list of GroupEntity
  Future<List<GroupEntity>> call(String userId) {
    return _groupRepository.getUserGroups(userId);
  }
}
