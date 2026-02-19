enum KtpCategory { umum, khusus }

enum KhususCategory { lansia, odgj }

extension KtpCategoryExtension on KtpCategory {
  String get label {
    switch (this) {
      case KtpCategory.umum:
        return 'Umum';
      case KtpCategory.khusus:
        return 'Khusus (Lansia/ODGJ)';
    }
  }

  String get value {
    switch (this) {
      case KtpCategory.umum:
        return 'umum';
      case KtpCategory.khusus:
        return 'khusus';
    }
  }

  int get minimalJumlah {
    switch (this) {
      case KtpCategory.umum:
        return 15;
      case KtpCategory.khusus:
        return 1;
    }
  }

  int get minimalUsia {
    switch (this) {
      case KtpCategory.umum:
        return 16;
      case KtpCategory.khusus:
        return 60; // Will be overridden by khususCategory
    }
  }
}

extension KhususCategoryExtension on KhususCategory {
  String get label {
    switch (this) {
      case KhususCategory.lansia:
        return 'Lansia (Usia 60+)';
      case KhususCategory.odgj:
        return 'ODGJ (Usia 17+)';
    }
  }

  String get value {
    switch (this) {
      case KhususCategory.lansia:
        return 'lansia';
      case KhususCategory.odgj:
        return 'odgj';
    }
  }

  int get minimalUsia {
    switch (this) {
      case KhususCategory.lansia:
        return 60;
      case KhususCategory.odgj:
        return 17;
    }
  }
}
