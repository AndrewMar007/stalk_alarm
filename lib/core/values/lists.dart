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
    Oblast(uid: "oblast_31", title: "м. Київ"),
    Oblast(uid: "oblast_4", title: "Вінницька область"),
    Oblast(uid: "oblast_8", title: "Волинська область"),
    Oblast(uid: "oblast_9", title: "Дніпропетровська область"),
    Oblast(uid: "oblast_28", title: "Донецька область"),
    Oblast(uid: "oblast_10", title: "Житомирська область"),
    Oblast(uid: "oblast_11", title: "Закарпатська область"),
    Oblast(uid: "oblast_12", title: "Запорізька область"),
    Oblast(uid: "oblast_13", title: "Івано-Франківська область"),
    Oblast(uid: "oblast_14", title: "Київська область"),
    Oblast(uid: "oblast_15", title: "Кіровоградська область"),
    Oblast(uid: "oblast_16", title: "Луганська область"),
    Oblast(uid: "oblast_27", title: "Львівська область"),
    Oblast(uid: "oblast_17", title: "Миколаївська область"),
    Oblast(uid: "oblast_18", title: "Одеська область"),
    Oblast(uid: "oblast_19", title: "Полтавська область"),
    Oblast(uid: "oblast_5", title: "Рівненська область"),
    Oblast(uid: "oblast_20", title: "Сумська область"),
    Oblast(uid: "oblast_21", title: "Тернопільська область"),
    Oblast(uid: "oblast_22", title: "Харківська область"),
    Oblast(uid: "oblast_23", title: "Херсонська область"),
    Oblast(uid: "oblast_3", title: "Хмельницька область"),
    Oblast(uid: "oblast_24", title: "Черкаська область"),
    Oblast(uid: "oblast_26", title: "Чернівецька область"),
    Oblast(uid: "oblast_25", title: "Чернігівська область"),
  ];

  static const List<Raion> raions = [
    //!? Київська область
    Raion(
      uid: "raion_73",
      oblastUid: "oblast_14",
      title: "Білоцерківський район",
    ),
    Raion(
      uid: "raion_78",
      oblastUid: "oblast_14",
      title: "Бориспільський район",
    ),
    Raion(uid: "raion_79", oblastUid: "oblast_14", title: "Броварський район"),
    Raion(uid: "raion_75", oblastUid: "oblast_14", title: "Бучанський район"),
    Raion(
      uid: "raion_74",
      oblastUid: "oblast_14",
      title: "Вишгородський район",
    ),
    Raion(uid: "raion_76", oblastUid: "oblast_14", title: "Обухівський район"),
    Raion(uid: "raion_77", oblastUid: "oblast_14", title: "Фастівський район"),

    //!? Харківська область
    Raion(
      uid: "raion_126",
      oblastUid: "oblast_22",
      title: "Богодухівський район",
    ),
    Raion(uid: "raion_1902", oblastUid: "oblast_22", title: "Ізюмський район"),
    Raion(
      uid: "raion_127",
      oblastUid: "oblast_22",
      title: "Берестинський район",
    ),
    Raion(uid: "raion_123", oblastUid: "oblast_22", title: "Куп’янський район"),
    Raion(uid: "raion_128", oblastUid: "oblast_22", title: "Лозівський район"),
    Raion(uid: "raion_124", oblastUid: "oblast_22", title: "Харківський район"),
    Raion(uid: "raion_122", oblastUid: "oblast_22", title: "Чугуївський район"),

    //!? Черкаська область
    Raion(
      uid: "raion_150",
      oblastUid: "oblast_24",
      title: "Звенигородський район",
    ),
    Raion(
      uid: "raion_153",
      oblastUid: "oblast_24",
      title: "Золотоніський район",
    ),
    Raion(uid: "raion_151", oblastUid: "oblast_24", title: "Уманський район"),
    Raion(uid: "raion_152", oblastUid: "oblast_24", title: "Черкаський район"),

    //!? Вінницька область
    Raion(uid: "raion_36", oblastUid: "oblast_4", title: "Вінницький район"),
    Raion(uid: "raion_37", oblastUid: "oblast_4", title: "Гайсинський район"),
    Raion(uid: "raion_35", oblastUid: "oblast_4", title: "Жмеринський район"),
    Raion(
      uid: "raion_33",
      oblastUid: "oblast_4",
      title: "Могилів-Подільський район",
    ),
    Raion(uid: "raion_32", oblastUid: "oblast_4", title: "Тульчинський район"),
    Raion(uid: "raion_34", oblastUid: "oblast_4", title: "Хмільницький район"),

    //!? Волинська область
    Raion(
      uid: "raion_38",
      oblastUid: "oblast_8",
      title: "Володимирський район",
    ),
    Raion(
      uid: "raion_41",
      oblastUid: "oblast_8",
      title: "Камінь-Каширський район",
    ),
    Raion(uid: "raion_40", oblastUid: "oblast_8", title: "Ковельський район"),
    Raion(uid: "raion_39", oblastUid: "oblast_8", title: "Луцький район"),

    //!? Дніпропетровська область
    Raion(
      uid: "raion_44",
      oblastUid: "oblast_9",
      title: "Дніпровський район",
    ),
    Raion(
      uid: "raion_42",
      oblastUid: "oblast_9",
      title: "Кам’янський район",
    ),
    Raion(
      uid: "raion_46",
      oblastUid: "oblast_9",
      title: "Криворізький район",
    ),
    Raion(
      uid: "raion_47",
      oblastUid: "oblast_9",
      title: "Нікопольський район",
    ),
    Raion(
      uid: "raion_43",
      oblastUid: "oblast_9",
      title: "Самарівський район",
    ),
    Raion(
      uid: "raion_45",
      oblastUid: "oblast_9",
      title: "Павлоградський район",
    ),
    Raion(
      uid: "raion_48",
      oblastUid: "oblast_9",
      title: "Синельниківський район",
    ),

    //!? Донецька область
    Raion(
      uid: "raion_54",
      oblastUid: "oblast_28",
      title: "Бахмутський район",
    ),
    Raion(
      uid: "raion_55",
      oblastUid: "oblast_28",
      title: "Волноваський район",
    ),
    Raion(
      uid: "raion_51",
      oblastUid: "oblast_28",
      title: "Горлівський район",
    ),
    Raion(uid: "raion_53", oblastUid: "oblast_04", title: "Донецький район"),
    Raion(
      uid: "raion_49",
      oblastUid: "oblast_28",
      title: "Кальміуський район",
    ),
    Raion(
      uid: "raion_50",
      oblastUid: "oblast_28",
      title: "Краматорський район",
    ),
    Raion(
      uid: "raion_52",
      oblastUid: "oblast_28",
      title: "Маріупольський район",
    ),
    Raion(
      uid: "raion_56",
      oblastUid: "oblast_28",
      title: "Покровський район",
    ),

    //!? Житомирська область
    Raion(
      uid: "raion_57",
      oblastUid: "oblast_10",
      title: "Бердичівський район",
    ),
    Raion(
      uid: "raion_59",
      oblastUid: "oblast_10",
      title: "Житомирський район",
    ),
    Raion(
      uid: "raion_60",
      oblastUid: "oblast_10",
      title: "Звягельський район",
    ),
    Raion(
      uid: "raion_58",
      oblastUid: "oblast_10",
      title: "Коростенський район",
    ),

    //!? Закарпатська область
    Raion(
      uid: "raion_61",
      oblastUid: "oblast_11",
      title: "Берегівський район",
    ),
    Raion(
      uid: "raion_65",
      oblastUid: "oblast_11",
      title: "Мукачівський район",
    ),
    Raion(uid: "raion_63", oblastUid: "oblast_11", title: "Рахівський район"),
    Raion(uid: "raion_64", oblastUid: "oblast_11", title: "Тячівський район"),
    Raion(
      uid: "raion_66",
      oblastUid: "oblast_11",
      title: "Ужгородський район",
    ),
    Raion(uid: "raion_62", oblastUid: "oblast_11", title: "Хустський район"),

    //!? Запорізька область
    Raion(
      uid: "raion_147",
      oblastUid: "oblast_12",
      title: "Бердянський район",
    ),
    Raion(
      uid: "raion_149",
      oblastUid: "oblast_12",
      title: "Запорізький район",
    ),
    Raion(
      uid: "raion_148",
      oblastUid: "oblast_12",
      title: "Мелітопольський район",
    ),
    Raion(
      uid: "raion_145",
      oblastUid: "oblast_12",
      title: "Пологівський район",
    ),
    Raion(
      uid: "raion_146",
      oblastUid: "oblast_12",
      title: "Василівський район",
    ),

    //!? Івано-Франківська область
    Raion(
      uid: "raion_67",
      oblastUid: "oblast_13",
      title: "Верховинський район",
    ),
    Raion(
      uid: "raion_68",
      oblastUid: "oblast_13",
      title: "Івано-Франківський район",
    ),
    Raion(uid: "raion_71", oblastUid: "oblast_13", title: "Калуський район"),
    Raion(
      uid: "raion_70",
      oblastUid: "oblast_13",
      title: "Коломийський район",
    ),
    Raion(uid: "raion_69", oblastUid: "oblast_13", title: "Косівський район"),
    Raion(
      uid: "raion_72",
      oblastUid: "oblast_13",
      title: "Надвірнянський район",
    ),

    //!? Чернігівська область
    Raion(
      uid: "raion_144",
      oblastUid: "oblast_25",
      title: "Корюківський район",
    ),
    Raion(uid: "raion_142", oblastUid: "oblast_25", title: "Ніжинський район"),
    Raion(
      uid: "raion_141",
      oblastUid: "oblast_25",
      title: "Новгород-Сіверський район",
    ),
    Raion(uid: "raion_143", oblastUid: "oblast_25", title: "Прилуцький район"),
    Raion(
      uid: "raion_140",
      oblastUid: "oblast_25",
      title: "Чернігівський район",
    ),

    //!? Полтавська область
    Raion(uid: "raion_106", oblastUid: "oblast_19", title: "Лубенський район"),
    Raion(
      uid: "raion_108",
      oblastUid: "oblast_19",
      title: "Миргородський район",
    ),
    Raion(
      uid: "raion_107",
      oblastUid: "oblast_19",
      title: "Кременчуцький район",
    ),
    Raion(
      uid: "raion_109",
      oblastUid: "oblast_19",
      title: "Полтавський район",
    ),

    //!? Сумська область
    Raion(
      uid: "raion_117",
      oblastUid: "oblast_20",
      title: "Конотопський район",
    ),
    Raion(uid: "raion_118", oblastUid: "oblast_20", title: "Охтирський район"),
    Raion(uid: "raion_116", oblastUid: "oblast_20", title: "Роменський район"),
    Raion(uid: "raion_114", oblastUid: "oblast_20", title: "Сумський район"),
    Raion(
      uid: "raion_115",
      oblastUid: "oblast_20",
      title: "Шосткинський район",
    ),

    //!? Тернопільска область
    Raion(
      uid: "raion_120",
      oblastUid: "oblast_21",
      title: "Кременецький район",
    ),
    Raion(
      uid: "raion_119",
      oblastUid: "oblast_21",
      title: "Тернопільський район",
    ),
    Raion(
      uid: "raion_121",
      oblastUid: "oblast_21",
      title: "Чортківський район",
    ),

    //!? Кіровоградська область
    Raion(
      uid: "raion_82",
      oblastUid: "oblast_15",
      title: "Голованівський район",
    ),
    Raion(
      uid: "raion_81",
      oblastUid: "oblast_15",
      title: "Кропивницький район",
    ),
    Raion(
      uid: "raion_83",
      oblastUid: "oblast_15",
      title: "Новоукраїнський район",
    ),
    Raion(
      uid: "raion_80",
      oblastUid: "oblast_15",
      title: "Олександрійський район",
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
    ),
    Raion(
      uid: "raion_86",
      oblastUid: "oblast_16",
      title: "Старобільський район",
    ),
    Raion(
      uid: "raion_84",
      oblastUid: "oblast_16",
      title: "Сіверськодонецький район",
    ),
    Raion(
      uid: "raion_87",
      oblastUid: "oblast_16",
      title: "Щастинський район",
    ),

    //!? Львівська область
    Raion(
      uid: "raion_91",
      oblastUid: "oblast_27",
      title: "Дрогобицький район",
    ),
    Raion(
      uid: "raion_94",
      oblastUid: "oblast_27",
      title: "Золочівський район",
    ),
    Raion(uid: "raion_90", oblastUid: "oblast_27", title: "Львівський район"),
    Raion(
      uid: "raion_88",
      oblastUid: "oblast_27",
      title: "Самбірський район",
    ),
    Raion(uid: "raion_89", oblastUid: "oblast_27", title: "Стрийський район"),
    Raion(uid: "raion_92", oblastUid: "oblast_27", title: "Шептицький район"),
    Raion(
      uid: "raion_93",
      oblastUid: "oblast_27",
      title: "Яворівський район",
    ),

    //! Миколаївська область
    Raion(
      uid: "raion_96",
      oblastUid: "oblast_17",
      title: "Баштанський район",
    ),
    Raion(
      uid: "raion_95",
      oblastUid: "oblast_17",
      title: "Вознесенський район",
    ),
    Raion(
      uid: "raion_98",
      oblastUid: "oblast_17",
      title: "Миколаївський район",
    ),
    Raion(
      uid: "raion_97",
      oblastUid: "oblast_17",
      title: "Первомайський район",
    ),

    //!? Одеська область
    Raion(
      uid: "raion_100",
      oblastUid: "oblast_18",
      title: "Березівський район",
    ),
    Raion(
      uid: "raion_105",
      oblastUid: "oblast_18",
      title: "Болградський район",
    ),
    Raion(
      uid: "raion_102",
      oblastUid: "oblast_18",
      title: "Білгород-Дністровський район",
    ),
    Raion(uid: "raion_104", oblastUid: "oblast_18", title: "Одеський район"),
    Raion(
      uid: "raion_99",
      oblastUid: "oblast_18",
      title: "Подільський район",
    ),
    Raion(
      uid: "raion_103",
      oblastUid: "oblast_18",
      title: "Роздільнянський район",
    ),
    Raion(
      uid: "raion_101",
      oblastUid: "oblast_18",
      title: "Ізмаїльський район",
    ),

    //!? Рівненська область
    Raion(uid: "raion_110", oblastUid: "oblast_5", title: "Вараський район"),
    Raion(uid: "raion_111", oblastUid: "oblast_5", title: "Дубенський район"),
    Raion(
      uid: "raion_112",
      oblastUid: "oblast_5",
      title: "Рівненський район",
    ),
    Raion(
      uid: "raion_113",
      oblastUid: "oblast_5",
      title: "Сарненський район",
    ),

    //!? Чернівецька область
    Raion(uid: "raion_138", oblastUid: "oblast_26", title: "Вижницький район"),
    Raion(
      uid: "raion_139",
      oblastUid: "oblast_26",
      title: "Дністровський район",
    ),
    Raion(
      uid: "raion_137",
      oblastUid: "oblast_26",
      title: "Чернівецький район",
    ),

    //!? Хмельницька область
    Raion(
      uid: "raion_135",
      oblastUid: "oblast_3",
      title: "Кам'янець-Подільський район",
    ),
    Raion(
      uid: "raion_134",
      oblastUid: "oblast_3",
      title: "Хмельницький район",
    ),
    Raion(
      uid: "raion_136",
      oblastUid: "oblast_3",
      title: "Шепетівський район",
    ),

    //!? Херсонська область
    Raion(
      uid: "raion_129",
      oblastUid: "oblast_23",
      title: "Бериславський район",
    ),
    Raion(
      uid: "raion_133",
      oblastUid: "oblast_23",
      title: "Генічеський район",
    ),
    Raion(uid: "raion_131", oblastUid: "oblast_23", title: "Каховський район"),
    Raion(
      uid: "raion_130",
      oblastUid: "oblast_23",
      title: "Скадовський район",
    ),
    Raion(
      uid: "raion_132",
      oblastUid: "oblast_23",
      title: "Херсонський район",
    ),
  ];
}
