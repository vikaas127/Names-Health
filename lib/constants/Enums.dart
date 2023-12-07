enum LoginType { normal, google, linkedin, ios }

enum DocumentType { qualification, certificate, inservice, credential }

extension LoginTypeExtension on LoginType {
  String get name {
    switch (this) {
      case LoginType.normal:
        return 'normal';
      case LoginType.google:
        return 'google';
      case LoginType.linkedin:
        return 'linkedin';
      case LoginType.ios:
        return 'apple';
      default:
        return null;
    }
  }
}
