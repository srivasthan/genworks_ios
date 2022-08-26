class TrainingModel {
  String? trainingId;
  String? trainingTitle;
  String? certificateId;
  String? trainingThumbImage;
  String? trainingContentType;
  String? trainingContent;
  bool? showPdfBadge;
  bool? showWordBadge;
  bool? showFileBadge;
  bool? showLinkBadge;

  TrainingModel({
    this.trainingId,
    this.trainingTitle,
    this.certificateId,
    this.trainingThumbImage,
    this.trainingContentType,
    this.trainingContent,
    this.showFileBadge,
    this.showLinkBadge,
    this.showWordBadge,
    this.showPdfBadge
  });
}