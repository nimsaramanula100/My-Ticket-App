// lib/utils/category_data.dart
// ─────────────────────────────────────────────────────────────────────────────
// CategoryData | සිදුවීම් කාණ්ඩ සහ උපකාණ්ඩ දත්ත (Category & Subcategory Data)
// Centralized mapping of main categories and their respective subcategories.
// ප්‍රධාන කාණ්ඩ සහ ඒවාට අදාළ උපකාණ්ඩ ලැයිස්තුගත කර ඇති මධ්‍යම දත්ත ගොනුව.
// ─────────────────────────────────────────────────────────────────────────────

class CategoryData {
  // Map of all Main Categories to their Subcategories
  // ප්‍රධාන කාණ්ඩ සියල්ල සහ ඒවායේ උපකාණ්ඩ දක්වන Map එක
  static const Map<String, List<String>> hierarchy = {
    'Music & Concerts': [
      'Concert',
      'EDM',
      'Classical',
      'Orchestral',
      'Musical Festival',
      'DJ',
    ],
    'Business & Learning': [
      'Educational',
      'Seminar',
      'Conference',
      'Tech',
      'Exhibition',
    ],
    'Team Sports': [
      'Cricket',
      'Rugby',
      'Football',
      'Basketball',
      'Volleyball',
    ],
    'Individual & Motor Sports': [
      'Motor Sport',
      'Golf',
      'Boxing',
    ],
    'Family & More': [
      'Children',
      'Sport Festival',
      'Dinner Dance',
      'Festival',
      'Free',
      'Online',
      'Other',
    ],
    'Movies & Theatre': [
      'Movie',
      'Drama',
      'Comedy',
      'Lionel Wendt Theatre',
    ],
  };

  // Top level categories for mega menus or main tabs
  // ප්‍රධාන මෙනු සඳහා ඉහළම මට්ටමේ කාණ්ඩ ලැයිස්තුව
  static const List<String> mainCategories = [
    'Music & Concerts',
    'Business & Learning',
    'Team Sports',
    'Individual & Motor Sports',
    'Family & More',
    'Movies & Theatre',
  ];

  // Helper method to get subcategories for a specific main category
  // ලබා දෙන ප්‍රධාන කාණ්ඩය සඳහා අදාළ උපකාණ්ඩ ලබා දෙන සහකාර ශ්‍රිතය
  static List<String> getSubcategories(String mainCategory) {
    return hierarchy[mainCategory] ?? [];
  }

  // Helper method to get the main category from a subcategory
  // උපකාණ්ඩයෙන් ප්‍රධාන කාණ්ඩය තොරතුරු ලබා දෙන සහකාර ශ්‍රිතය
  static String? getMainCategoryFromSubcategory(String subcategory) {
    for (final entry in hierarchy.entries) {
      if (entry.value.contains(subcategory)) {
        return entry.key;
      }
    }
    return null;
  }
}
