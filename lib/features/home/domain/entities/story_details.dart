import 'package:comicsapp/features/home/domain/entities/chapter.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';

// Model này gộp thông tin truyện và danh sách chương
class StoryDetails {
  final Story story;
  final List<Chapter> chapters;

  StoryDetails({required this.story, required this.chapters});

  factory StoryDetails.fromRpcResponse(Map<String, dynamic> response) {
    final storyData = response['story'];
    final chaptersData = response['chapters'] as List?;
    
    return StoryDetails(
      story: Story.fromMap(storyData as Map<String, dynamic>),
      chapters: chaptersData?.map((c) => Chapter.fromMap(c as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
