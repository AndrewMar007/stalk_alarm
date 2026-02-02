import '../../models/admin_units.dart';

class ListsOfAdministrativeUnits {
  // static const List<String> ukraineRegions = [
  //   'м. Київ',
  //   'Вінницька область',
  //   'Волинська область',
  //   'Дніпропетровська область',
  //   'Донецька область',
  //   'Житомирська область',
  //   'Закарпатська область',
  //   'Запорізька область',
  //   'Івано-Франківська область',
  //   'Київська область',
  //   'Кіровоградська область',
  //   'Луганська область',
  //   'Львівська область',
  //   'Миколаївська область',
  //   'Одеська область',
  //   'Полтавська область',
  //   'Рівненська область',
  //   'Сумська область',
  //   'Тернопільська область',
  //   'Харківська область',
  //   'Херсонська область',
  //   'Хмельницька область',
  //   'Черкаська область',
  //   'Чернівецька область',
  //   'Чернігівська область',
  // ];

  static const List<Oblast> oblasts = [
    Oblast(uid: "oblast_31", title: "м. Київ", titleEng: "Kyiv"),
    Oblast(
      uid: "oblast_4",
      title: "Вінницька область",
      titleEng: "Vinnytska region",
    ),
    Oblast(
      uid: "oblast_8",
      title: "Волинська область",
      titleEng: "Volynska region",
    ),
    Oblast(
      uid: "oblast_9",
      title: "Дніпропетровська область",
      titleEng: "Dnipropetrovska region",
    ),
    Oblast(
      uid: "oblast_28",
      title: "Донецька область",
      titleEng: "Donetska region",
    ),
    Oblast(
      uid: "oblast_10",
      title: "Житомирська область",
      titleEng: "Zhytomyrska region",
    ),
    Oblast(
      uid: "oblast_11",
      title: "Закарпатська область",
      titleEng: "Zakarpatska region",
    ),
    Oblast(
      uid: "oblast_12",
      title: "Запорізька область",
      titleEng: "Zaporizka region",
    ),
    Oblast(
      uid: "oblast_13",
      title: "Івано-Франківська область",
      titleEng: "Ivano-Frankivska region",
    ),
    Oblast(
      uid: "oblast_14",
      title: "Київська область",
      titleEng: "Kyivska region",
    ),
    Oblast(
      uid: "oblast_15",
      title: "Кіровоградська область",
      titleEng: "Kirovohradska region",
    ),
    Oblast(
      uid: "oblast_16",
      title: "Луганська область",
      titleEng: "Luhanska region",
    ),
    Oblast(
      uid: "oblast_27",
      title: "Львівська область",
      titleEng: "Lvivska region",
    ),
    Oblast(
      uid: "oblast_17",
      title: "Миколаївська область",
      titleEng: "Mykolaivska region",
    ),
    Oblast(
      uid: "oblast_18",
      title: "Одеська область",
      titleEng: "Odeska region",
    ),
    Oblast(
      uid: "oblast_19",
      title: "Полтавська область",
      titleEng: "Poltavska region",
    ),
    Oblast(
      uid: "oblast_5",
      title: "Рівненська область",
      titleEng: "Rivnenska region",
    ),
    Oblast(
      uid: "oblast_20",
      title: "Сумська область",
      titleEng: "Sumska region",
    ),
    Oblast(
      uid: "oblast_21",
      title: "Тернопільська область",
      titleEng: "Ternopilska region",
    ),
    Oblast(
      uid: "oblast_22",
      title: "Харківська область",
      titleEng: "Kharkivska region",
    ),
    Oblast(
      uid: "oblast_23",
      title: "Херсонська область",
      titleEng: "Khersonska region",
    ),
    Oblast(
      uid: "oblast_3",
      title: "Хмельницька область",
      titleEng: "Khmelnytska region",
    ),
    Oblast(
      uid: "oblast_24",
      title: "Черкаська область",
      titleEng: "Cherkaska region",
    ),
    Oblast(
      uid: "oblast_26",
      title: "Чернівецька область",
      titleEng: "Chernivetska region",
    ),
    Oblast(
      uid: "oblast_25",
      title: "Чернігівська область",
      titleEng: "Chernihivska region",
    ),
    Oblast(uid: "oblast_29", title: "АР Крим", titleEng: ""),
  ];

  static const List<Raion> raions = [
    //!? Київська область
    Raion(
      uid: "raion_73",
      oblastUid: "oblast_14",
      title: "Білоцерківський район",
      titleEng: "Bilotserkivskyi district",
    ),
    Raion(
      uid: "raion_78",
      oblastUid: "oblast_14",
      title: "Бориспільський район",
      titleEng: "Boryspilskyi district",
    ),
    Raion(
      uid: "raion_79",
      oblastUid: "oblast_14",
      title: "Броварський район",
      titleEng: "Brovarskyi district",
    ),
    Raion(
      uid: "raion_75",
      oblastUid: "oblast_14",
      title: "Бучанський район",
      titleEng: "Buchanskyi district",
    ),
    Raion(
      uid: "raion_74",
      oblastUid: "oblast_14",
      title: "Вишгородський район",
      titleEng: "Vyshhorodskyi district",
    ),
    Raion(
      uid: "raion_76",
      oblastUid: "oblast_14",
      title: "Обухівський район",
      titleEng: "Obukhiskyi district",
    ),
    Raion(
      uid: "raion_77",
      oblastUid: "oblast_14",
      title: "Фастівський район",
      titleEng: "Fastivskyi district",
    ),

    //!? Харківська область
    Raion(
      uid: "raion_126",
      oblastUid: "oblast_22",
      title: "Богодухівський район",
      titleEng: "Bohodukhivskyi district",
    ),
    Raion(
      uid: "raion_1902",
      oblastUid: "oblast_22",
      title: "Ізюмський район",
      titleEng: "Iziumskyi district",
    ),
    Raion(
      uid: "raion_127",
      oblastUid: "oblast_22",
      title: "Берестинський район",
      titleEng: "Berestyn district",
    ),
    Raion(
      uid: "raion_123",
      oblastUid: "oblast_22",
      title: "Куп’янський район",
      titleEng: "Kupianskyi district",
    ),
    Raion(
      uid: "raion_128",
      oblastUid: "oblast_22",
      title: "Лозівський район",
      titleEng: "Lozivskyi district",
    ),
    Raion(
      uid: "raion_124",
      oblastUid: "oblast_22",
      title: "Харківський район",
      titleEng: "Kharkivskyi district",
    ),
    Raion(
      uid: "raion_122",
      oblastUid: "oblast_22",
      title: "Чугуївський район",
      titleEng: "Chuhuivskyi district",
    ),

    //!? Черкаська область
    Raion(
      uid: "raion_150",
      oblastUid: "oblast_24",
      title: "Звенигородський район",
      titleEng: "Zvenyhorodskyi district",
    ),
    Raion(
      uid: "raion_153",
      oblastUid: "oblast_24",
      title: "Золотоніський район",
      titleEng: "Zolotoniskyi district",
    ),
    Raion(
      uid: "raion_151",
      oblastUid: "oblast_24",
      title: "Уманський район",
      titleEng: "Umanskyi district",
    ),
    Raion(
      uid: "raion_152",
      oblastUid: "oblast_24",
      title: "Черкаський район",
      titleEng: "Cherkaskyi district",
    ),

    //!? Вінницька область
    Raion(
      uid: "raion_36",
      oblastUid: "oblast_4",
      title: "Вінницький район",
      titleEng: "Vinnytskyi district",
    ),
    Raion(
      uid: "raion_37",
      oblastUid: "oblast_4",
      title: "Гайсинський район",
      titleEng: "Haisynskyi district",
    ),
    Raion(
      uid: "raion_35",
      oblastUid: "oblast_4",
      title: "Жмеринський район",
      titleEng: "Zhmerynskyi district",
    ),
    Raion(
      uid: "raion_33",
      oblastUid: "oblast_4",
      title: "Могилів-Подільський район",
      titleEng: "Mohyliv-Podilskyi district",
    ),
    Raion(
      uid: "raion_32",
      oblastUid: "oblast_4",
      title: "Тульчинський район",
      titleEng: "Tulchynskyi district",
    ),
    Raion(
      uid: "raion_34",
      oblastUid: "oblast_4",
      title: "Хмільницький район",
      titleEng: "Khmilnytskyi district",
    ),

    //!? Волинська область
    Raion(
      uid: "raion_38",
      oblastUid: "oblast_8",
      title: "Володимирський район",
      titleEng: "Volodymyr district",
    ),
    Raion(
      uid: "raion_41",
      oblastUid: "oblast_8",
      title: "Камінь-Каширський район",
      titleEng: "Kamin-Kashyrskyi district",
    ),
    Raion(
      uid: "raion_40",
      oblastUid: "oblast_8",
      title: "Ковельський район",
      titleEng: "Kovelskiy district",
    ),
    Raion(
      uid: "raion_39",
      oblastUid: "oblast_8",
      title: "Луцький район",
      titleEng: "Lutskiy district",
    ),

    //!? Дніпропетровська область
    Raion(
      uid: "raion_44",
      oblastUid: "oblast_9",
      title: "Дніпровський район",
      titleEng: "Dniprovskyi district",
    ),
    Raion(
      uid: "raion_42",
      oblastUid: "oblast_9",
      title: "Кам’янський район",
      titleEng: "Kamianskyi district",
    ),
    Raion(
      uid: "raion_46",
      oblastUid: "oblast_9",
      title: "Криворізький район",
      titleEng: "Kryvorizkyi district",
    ),
    Raion(
      uid: "raion_47",
      oblastUid: "oblast_9",
      title: "Нікопольський район",
      titleEng: "Nikopolskyi district",
    ),
    Raion(
      uid: "raion_43",
      oblastUid: "oblast_9",
      title: "Самарівський район",
      titleEng: "Samarskyi district",
    ),
    Raion(
      uid: "raion_45",
      oblastUid: "oblast_9",
      title: "Павлоградський район",
      titleEng: "Pavlohradskyi district",
    ),
    Raion(
      uid: "raion_48",
      oblastUid: "oblast_9",
      title: "Синельниківський район",
      titleEng: "Synelnykivskyi district",
    ),

    //!? Донецька область
    Raion(
      uid: "raion_54",
      oblastUid: "oblast_28",
      title: "Бахмутський район",
      titleEng: "Bakhmutskyi district",
    ),
    Raion(
      uid: "raion_55",
      oblastUid: "oblast_28",
      title: "Волноваський район",
      titleEng: "Volnovaskyi district",
    ),
    Raion(
      uid: "raion_51",
      oblastUid: "oblast_28",
      title: "Горлівський район",
      titleEng: "Horlivskiy district",
    ),
    Raion(
      uid: "raion_53",
      oblastUid: "oblast_04",
      title: "Донецький район",
      titleEng: "Donetskyi district",
    ),
    Raion(
      uid: "raion_49",
      oblastUid: "oblast_28",
      title: "Кальміуський район",
      titleEng: "Kalmiuskyi district",
    ),
    Raion(
      uid: "raion_50",
      oblastUid: "oblast_28",
      title: "Краматорський район",
      titleEng: "Kramatorskiy district",
    ),
    Raion(
      uid: "raion_52",
      oblastUid: "oblast_28",
      title: "Маріупольський район",
      titleEng: "Mariupolskyi district",
    ),
    Raion(
      uid: "raion_56",
      oblastUid: "oblast_28",
      title: "Покровський район",
      titleEng: "Pokrovskyi district",
    ),

    //!? Житомирська область
    Raion(
      uid: "raion_57",
      oblastUid: "oblast_10",
      title: "Бердичівський район",
      titleEng: "Berdychivskyi district",
    ),
    Raion(
      uid: "raion_59",
      oblastUid: "oblast_10",
      title: "Житомирський район",
      titleEng: "Zhytomyrskyi district",
    ),
    Raion(
      uid: "raion_60",
      oblastUid: "oblast_10",
      title: "Звягельський район",
      titleEng: "Zviahel district",
    ),
    Raion(
      uid: "raion_58",
      oblastUid: "oblast_10",
      title: "Коростенський район",
      titleEng: "Korostenskyi district",
    ),

    //!? Закарпатська область
    Raion(
      uid: "raion_61",
      oblastUid: "oblast_11",
      title: "Берегівський район",
      titleEng: "Berehiskyi district",
    ),
    Raion(
      uid: "raion_65",
      oblastUid: "oblast_11",
      title: "Мукачівський район",
      titleEng: "Mukachivskyi district",
    ),
    Raion(
      uid: "raion_63",
      oblastUid: "oblast_11",
      title: "Рахівський район",
      titleEng: "Rakhivskyi district",
    ),
    Raion(
      uid: "raion_64",
      oblastUid: "oblast_11",
      title: "Тячівський район",
      titleEng: "Tiachivskyi district",
    ),
    Raion(
      uid: "raion_66",
      oblastUid: "oblast_11",
      title: "Ужгородський район",
      titleEng: "Uzhhorodskyi district",
    ),
    Raion(
      uid: "raion_62",
      oblastUid: "oblast_11",
      title: "Хустський район",
      titleEng: "Khustskyi district",
    ),

    //!? Запорізька область
    Raion(
      uid: "raion_147",
      oblastUid: "oblast_12",
      title: "Бердянський район",
      titleEng: "Berdiasnkyi district",
    ),
    Raion(
      uid: "raion_149",
      oblastUid: "oblast_12",
      title: "Запорізький район",
      titleEng: "Zaporizkyi district",
    ),
    Raion(
      uid: "raion_148",
      oblastUid: "oblast_12",
      title: "Мелітопольський район",
      titleEng: "Melitopolskyi district",
    ),
    Raion(
      uid: "raion_145",
      oblastUid: "oblast_12",
      title: "Пологівський район",
      titleEng: "Polohiskyi district",
    ),
    Raion(
      uid: "raion_146",
      oblastUid: "oblast_12",
      title: "Василівський район",
      titleEng: "Vasylivskyi district",
    ),

    //!? Івано-Франківська область
    Raion(
      uid: "raion_67",
      oblastUid: "oblast_13",
      title: "Верховинський район",
      titleEng: "Verkhovynskyi district",
    ),
    Raion(
      uid: "raion_68",
      oblastUid: "oblast_13",
      title: "Івано-Франківський район",
      titleEng: "Ivano-Frankivskyi district",
    ),
    Raion(
      uid: "raion_71",
      oblastUid: "oblast_13",
      title: "Калуський район",
      titleEng: "Kaluskyi district",
    ),
    Raion(
      uid: "raion_70",
      oblastUid: "oblast_13",
      title: "Коломийський район",
      titleEng: "Kolomyiskyi district",
    ),
    Raion(
      uid: "raion_69",
      oblastUid: "oblast_13",
      title: "Косівський район",
      titleEng: "Kosivskyi district",
    ),
    Raion(
      uid: "raion_72",
      oblastUid: "oblast_13",
      title: "Надвірнянський район",
      titleEng: "Nadvirnianskyi district",
    ),

    //!? Чернігівська область
    Raion(
      uid: "raion_144",
      oblastUid: "oblast_25",
      title: "Корюківський район",
      titleEng: "Koriukivskyi district",
    ),
    Raion(
      uid: "raion_142",
      oblastUid: "oblast_25",
      title: "Ніжинський район",
      titleEng: "Nizhynskyi district",
    ),
    Raion(
      uid: "raion_141",
      oblastUid: "oblast_25",
      title: "Новгород-Сіверський район",
      titleEng: "Novhorod-Siverskyi district",
    ),
    Raion(
      uid: "raion_143",
      oblastUid: "oblast_25",
      title: "Прилуцький район",
      titleEng: "Prylutskyi district",
    ),
    Raion(
      uid: "raion_140",
      oblastUid: "oblast_25",
      title: "Чернігівський район",
      titleEng: "Chernihivskyi district",
    ),

    //!? Полтавська область
    Raion(
      uid: "raion_106",
      oblastUid: "oblast_19",
      title: "Лубенський район",
      titleEng: "Lubenskyi district",
    ),
    Raion(
      uid: "raion_108",
      oblastUid: "oblast_19",
      title: "Миргородський район",
      titleEng: "Myrhorodskyi district",
    ),
    Raion(
      uid: "raion_107",
      oblastUid: "oblast_19",
      title: "Кременчуцький район",
      titleEng: "Kremenchutskyi district",
    ),
    Raion(
      uid: "raion_109",
      oblastUid: "oblast_19",
      title: "Полтавський район",
      titleEng: "Poltavskyi district",
    ),

    //!? Сумська область
    Raion(
      uid: "raion_117",
      oblastUid: "oblast_20",
      title: "Конотопський район",
      titleEng: "Konotopskyi district",
    ),
    Raion(
      uid: "raion_118",
      oblastUid: "oblast_20",
      title: "Охтирський район",
      titleEng: "Okhtyrskyi district",
    ),
    Raion(
      uid: "raion_116",
      oblastUid: "oblast_20",
      title: "Роменський район",
      titleEng: "Romenskyi district",
    ),
    Raion(
      uid: "raion_114",
      oblastUid: "oblast_20",
      title: "Сумський район",
      titleEng: "Sumskyi district",
    ),
    Raion(
      uid: "raion_115",
      oblastUid: "oblast_20",
      title: "Шосткинський район",
      titleEng: "Shostkynskyi district",
    ),

    //!? Тернопільска область
    Raion(
      uid: "raion_120",
      oblastUid: "oblast_21",
      title: "Кременецький район",
      titleEng: "Kremenetskyi district",
    ),
    Raion(
      uid: "raion_119",
      oblastUid: "oblast_21",
      title: "Тернопільський район",
      titleEng: "Ternopilskyi district",
    ),
    Raion(
      uid: "raion_121",
      oblastUid: "oblast_21",
      title: "Чортківський район",
      titleEng: "Chortkivskyi district",
    ),

    //!? Кіровоградська область
    Raion(
      uid: "raion_82",
      oblastUid: "oblast_15",
      title: "Голованівський район",
      titleEng: "Holovanivskyi district",
    ),
    Raion(
      uid: "raion_81",
      oblastUid: "oblast_15",
      title: "Кропивницький район",
      titleEng: "Kropyvnytskyi district",
    ),
    Raion(
      uid: "raion_83",
      oblastUid: "oblast_15",
      title: "Новоукраїнський район",
      titleEng: "Novoukrainskyi district",
    ),
    Raion(
      uid: "raion_80",
      oblastUid: "oblast_15",
      title: "Олександрійський район",
      titleEng: "Oleksandriivskyi district",
    ),

    //!? Луганська область
    //! Не враховується  Raion(uid: "raion_1803", oblastUid: "oblast_16", title: "Алчевський район"),
    //! Не враховується
    //! Raion(
    //!   uid: "raion_1804",
    //!   oblastUid: "oblast_24",
    //!   title: "Довжанський район",
    //! ),
    //! Не враховується Raion(uid: "raion_1801", oblastUid: "oblast_16", title: "Луганський район"),
    //! Не враховується
    //! Raion(
    //!   uid: "raion_1802",
    //!   oblastUid: "oblast_16",
    //!   title: "Ровеньківський район",
    //! ),
    Raion(
      uid: "raion_85",
      oblastUid: "oblast_16",
      title: "Сватівський район",
      titleEng: "Svativskyi district",
    ),
    Raion(
      uid: "raion_86",
      oblastUid: "oblast_16",
      title: "Старобільський район",
      titleEng: "Starobilsky district",
    ),
    Raion(
      uid: "raion_84",
      oblastUid: "oblast_16",
      title: "Сіверськодонецький район",
      titleEng: "Sievierodonetsk district",
    ),
    Raion(
      uid: "raion_87",
      oblastUid: "oblast_16",
      title: "Щастинський район",
      titleEng: "Shchastynskyi district",
    ),

    //!? Львівська область
    Raion(
      uid: "raion_91",
      oblastUid: "oblast_27",
      title: "Дрогобицький район",
      titleEng: "Drohobytskyi district",
    ),
    Raion(
      uid: "raion_94",
      oblastUid: "oblast_27",
      title: "Золочівський район",
      titleEng: "Zolochivskyi district",
    ),
    Raion(
      uid: "raion_90",
      oblastUid: "oblast_27",
      title: "Львівський район",
      titleEng: "Lvivskyi district",
    ),
    Raion(
      uid: "raion_88",
      oblastUid: "oblast_27",
      title: "Самбірський район",
      titleEng: "Sambirskyi district",
    ),
    Raion(
      uid: "raion_89",
      oblastUid: "oblast_27",
      title: "Стрийський район",
      titleEng: "Stryiskyi district",
    ),
    Raion(
      uid: "raion_92",
      oblastUid: "oblast_27",
      title: "Шептицький район",
      titleEng: "Sheptytskyi district",
    ),
    Raion(
      uid: "raion_93",
      oblastUid: "oblast_27",
      title: "Яворівський район",
      titleEng: "Iavorivskyi district",
    ),

    //!? Миколаївська область
    Raion(
      uid: "raion_96",
      oblastUid: "oblast_17",
      title: "Баштанський район",
      titleEng: "Bashtanskyi district",
    ),
    Raion(
      uid: "raion_95",
      oblastUid: "oblast_17",
      title: "Вознесенський район",
      titleEng: "Voznesenskyi district",
    ),
    Raion(
      uid: "raion_98",
      oblastUid: "oblast_17",
      title: "Миколаївський район",
      titleEng: "Mykolaivskyi district",
    ),
    Raion(
      uid: "raion_97",
      oblastUid: "oblast_17",
      title: "Первомайський район",
      titleEng: "Pervomaiskyi district",
    ),

    //!? Одеська область
    Raion(
      uid: "raion_100",
      oblastUid: "oblast_18",
      title: "Березівський район",
      titleEng: "Berezivskyi district",
    ),
    Raion(
      uid: "raion_105",
      oblastUid: "oblast_18",
      title: "Болградський район",
      titleEng: "Bolhradskyi district",
    ),
    Raion(
      uid: "raion_102",
      oblastUid: "oblast_18",
      title: "Білгород-Дністровський район",
      titleEng: "Bilhorod-Dnistrovskyi district",
    ),
    Raion(
      uid: "raion_104",
      oblastUid: "oblast_18",
      title: "Одеський район",
      titleEng: "Odeskyi district",
    ),
    Raion(
      uid: "raion_99",
      oblastUid: "oblast_18",
      title: "Подільський район",
      titleEng: "Podilskyi district",
    ),
    Raion(
      uid: "raion_103",
      oblastUid: "oblast_18",
      title: "Роздільнянський район",
      titleEng: "Rozdilnianskyi district",
    ),
    Raion(
      uid: "raion_101",
      oblastUid: "oblast_18",
      title: "Ізмаїльський район",
      titleEng: "Izmailskyi district",
    ),

    //!? Рівненська область
    Raion(
      uid: "raion_110",
      oblastUid: "oblast_5",
      title: "Вараський район",
      titleEng: "Varaskyi district",
    ),
    Raion(
      uid: "raion_111",
      oblastUid: "oblast_5",
      title: "Дубенський район",
      titleEng: "Dubenskyi district",
    ),
    Raion(
      uid: "raion_112",
      oblastUid: "oblast_5",
      title: "Рівненський район",
      titleEng: "Rivnenskyi district",
    ),
    Raion(
      uid: "raion_113",
      oblastUid: "oblast_5",
      title: "Сарненський район",
      titleEng: "Sarneskyi district",
    ),

    //!? Чернівецька область
    Raion(
      uid: "raion_138",
      oblastUid: "oblast_26",
      title: "Вижницький район",
      titleEng: "Vyzhnytskyi district",
    ),
    Raion(
      uid: "raion_139",
      oblastUid: "oblast_26",
      title: "Дністровський район",
      titleEng: "Dnistrovskyi district",
    ),
    Raion(
      uid: "raion_137",
      oblastUid: "oblast_26",
      title: "Чернівецький район",
      titleEng: "Chernivetskyi district",
    ),

    //!? Хмельницька область
    Raion(
      uid: "raion_135",
      oblastUid: "oblast_3",
      title: "Кам'янець-Подільський район",
      titleEng: "Kamianets-Podilskyi district",
    ),
    Raion(
      uid: "raion_134",
      oblastUid: "oblast_3",
      title: "Хмельницький район",
      titleEng: "Khmelnytskyi district",
    ),
    Raion(
      uid: "raion_136",
      oblastUid: "oblast_3",
      title: "Шепетівський район",
      titleEng: "Shepetivskyi district",
    ),

    //!? Херсонська область
    Raion(
      uid: "raion_129",
      oblastUid: "oblast_23",
      title: "Бериславський район",
      titleEng: "Beryslavskyi district",
    ),
    Raion(
      uid: "raion_133",
      oblastUid: "oblast_23",
      title: "Генічеський район",
      titleEng: "Henicheskyi district",
    ),
    Raion(
      uid: "raion_131",
      oblastUid: "oblast_23",
      title: "Каховський район",
      titleEng: "Kakhovskyi district",
    ),
    Raion(
      uid: "raion_130",
      oblastUid: "oblast_23",
      title: "Скадовський район",
      titleEng: "Skadovskiy district",
    ),
    Raion(
      uid: "raion_132",
      oblastUid: "oblast_23",
      title: "Херсонський район",
      titleEng: "Khersonskyi district",
    ),
  ];
}
