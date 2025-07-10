// TODO: Move this data to Firebase
class WorkExperience {

  const WorkExperience({
    required this.company,
    required this.role,
    required this.startDate,
    this.endDate,
    this.type = '',
    required this.skills,
    this.url,
  });
  final String company;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final String type;
  final List<String> skills;
  final String? url;

  bool get isCurrent => endDate == null;

  String get duration {
    final now = DateTime.now();
    final end = endDate ?? now;
    final years = end.year - startDate.year;
    final months = end.month - startDate.month + (years * 12);

    final String formattedStart = '${_getMonth(startDate.month)} ${startDate.year}';
    final String formattedEnd = isCurrent
        ? 'Present'
        : '${_getMonth(end.month)} ${end.year}';

    String durationText = '';
    if (months >= 12) {
      final totalYears = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths > 0) {
        durationText = '(${totalYears}yr ${remainingMonths}mos)';
      } else {
        durationText = '(${totalYears}yr)';
      }
    } else {
      durationText = '(${months}mos)';
    }

    return '$formattedStart - $formattedEnd $durationText';
  }

  String _getMonth(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }
}

class WorkHistory {
  // TODO: Move this data to a database or API
  static final List<WorkExperience> experiences = [
    WorkExperience(
      company: 'Miquido',
      role: 'Flutter Developer',
      startDate: DateTime(2025, 6),
      skills: ['Flutter', 'iOS', 'Android', 'AI'],
    ),
    WorkExperience(
      company: 'Nextbank',
      role: 'Flutter Developer',
      startDate: DateTime(2023, 11),
      endDate: DateTime(2025, 6),
      skills: ['Web Dev', 'Mobile Apps', 'Flutter', 'Fintech'],
    ),
    WorkExperience(
      company: 'hedgehog lab',
      role: 'Mobile Engineer',
      startDate: DateTime(2022, 8),
      endDate: DateTime(2023, 11),
      type: 'Remote',
      skills: ['Flutter', 'Dart', 'Mobile Development'],
    ),
    WorkExperience(
      company: 'Craft-Tec Inc.',
      role: 'Software Engineer',
      startDate: DateTime(2021, 1),
      endDate: DateTime(2022, 8),
      type: 'Hybrid',
      skills: ['PHP', 'Flutter', 'Laravel', 'MySQL'],
    ),
    WorkExperience(
      company: 'Freelance',
      role: 'Web Developer',
      startDate: DateTime(2020, 6),
      endDate: DateTime(2021, 1),
      type: 'Remote',
      skills: ['JavaScript', 'Shopify'],
    ),
    WorkExperience(
      company: 'SystemsCore Inc.',
      role: 'Software Engineer',
      startDate: DateTime(2019, 4),
      endDate: DateTime(2020, 5),
      skills: ['ASP.NET', 'C#', 'JavaScript'],
    ),
  ];

  static String get totalExperience {
    if (experiences.isEmpty) return '0';
    final earliestDate = experiences.map((e) => e.startDate).reduce((a, b) => a.isBefore(b) ? a : b);
    final years = DateTime.now().year - earliestDate.year;
    return years.toString();
  }

  static const String specialization = 'Mobile App and Web Development';
  static const String currentStatus = 'Building amazing things';

  static WorkExperience? get currentJob =>
      experiences.where((exp) => exp.isCurrent).isNotEmpty
      ? experiences.where((exp) => exp.isCurrent).first
      : null;

  static List<WorkExperience> get previousJobs =>
      experiences.where((exp) => !exp.isCurrent).toList();
}
