class TrainingReferenceModel {
  int? trainingDetailsId;
  String? trainingId;
  String? trainingTitle;
  String? trainingThumbImage;
  String? trainingContentType;
  String? trainingContent;
  bool? showPdf;
  bool? showWord;
  bool? showFile;
  bool? showLink;

  TrainingReferenceModel({
    this.trainingDetailsId,
    this.trainingId,
    this.trainingTitle,
    this.trainingThumbImage,
    this.trainingContentType,
    this.trainingContent,
    this.showPdf,
    this.showWord,
    this.showFile,
    this.showLink
  });
}