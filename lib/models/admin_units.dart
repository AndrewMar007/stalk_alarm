
// class SavedAdminUnit{
//   final String oblastUid;
//   final String oblastTitle;
//   final String raionTitle;
//   final String raionUid;
//   final String hromadaTitle;
//   const SavedAdminUnit({required this.oblastUid, required this.oblastTitle, required this.raionTitle, required this.raionUid, required this.hromadaTitle});
// }

class Oblast {
  final String? uid; // умовний ID
  final String? title;

  const Oblast({required this.uid, required this.title});
}

class Raion {
  final String? uid;
  final String? oblastUid;
  final String? title;

  const Raion({
    required this.uid,
    required this.oblastUid,
    required this.title,
  });
}

class Hromada {
  final String? uid;
  final String? raionUid;
  final String? title;

  const Hromada({
    required this.uid,
    required this.raionUid,
    required this.title,
  });
}
