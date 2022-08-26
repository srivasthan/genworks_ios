import 'package:floor/floor.dart';

@entity
class TrainingListDataTable {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String? training_id;
  final String? training_title;
  final String? certificate_id;
  final String? training_thumb_image;
  final String? training_content_type;
  final String? training_content;
  final String? trainingPdfImage;
  final String? trainingVideoImage;
  final String? trainingWordImage;
  final String? trainingLinkImage;
  final bool? pdfCount;
  final bool? videoCount;
  final bool? wordCount;
  final bool? linkCount;
  final int? assessment_id;

  TrainingListDataTable({
    this.id,
    this.training_id,
    this.training_title,
    this.certificate_id,
    this.training_thumb_image,
    this.training_content_type,
    this.training_content,
    this.trainingPdfImage,
    this.trainingVideoImage,
    this.trainingWordImage,
    this.trainingLinkImage,
    this.pdfCount,
    this.videoCount,
    this.wordCount,
    this.linkCount,
    this.assessment_id});
}
