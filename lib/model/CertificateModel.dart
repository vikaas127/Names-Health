import 'dart:io';

class CertificateModel {
  File file;
  int id;
  int userId;
  String certificate;

  CertificateModel.name(this.file, this.id, this.userId, this.certificate);

  CertificateModel(this.file, this.id, this.userId, this.certificate);
}

// class QualificationModel {
//   File file;
//   int id;
//   int userId;
//   String certificate;

//   QualificationModel.name(this.file, this.id, this.userId, this.certificate);

//   QualificationModel(this.file, this.id, this.userId, this.certificate);
// }
