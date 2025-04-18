
import '../../data/repositories/post_repository.dart';
import '../entities/post_entity.dart';

/// Use case for getting posts for a specific group
class GetPostsUseCase {
  final PostRepository _postRepository;
  
  /// Constructor
  GetPostsUseCase(this._postRepository);
  
  /// Executes the get posts operation
  ///
  /// [groupId] - The ID of the group to get posts for
  Future<List<PostEntity>> call(String groupId) {
    return _postRepository.getGroupPosts(groupId);
  }
  
  /// Gets announcements for a specific group
  ///
  /// [groupId] - The ID of the group to get announcements for
  Future<List<PostEntity>> getAnnouncements(String groupId) {
    return _postRepository.getGroupAnnouncements(groupId);
  }
}
