import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/domain/work_experience.dart';
import 'package:sun_envidiado_website/utils/build_context_extensions.dart';

class Work extends StatelessWidget {
  const Work(this.fontScale, {super.key});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildTreeLine(context, '│'),
            _buildCurrentSection(context),
            _buildTreeLine(context, '│'),
            _buildPreviousSection(context),
            _buildTreeLine(context, '│'),
            _buildSummarySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _buildTreeLine(context, r'guest@terminal:~ $ /work experience/');
  }

  Widget _buildCurrentSection(BuildContext context) {
    final currentJob = WorkHistory.currentJob;
    if (currentJob == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTreeLine(context, '├── current/'),
        _buildWorkItem(context, currentJob, isCurrentJob: true),
      ],
    );
  }

  Widget _buildPreviousSection(BuildContext context) {
    final previousJobs = WorkHistory.previousJobs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTreeLine(context, '├── previous/'),
        ...previousJobs.asMap().entries.map((entry) {
          final index = entry.key;
          final job = entry.value;
          final isLast = index == previousJobs.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkItem(context, job, isLast: isLast),
              if (!isLast) _buildTreeLine(context, '│   │'),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildWorkItem(
    BuildContext context,
    WorkExperience item, {
    bool isCurrentJob = false,
    bool isLast = false,
  }) {
    final String prefix = isCurrentJob
        ? '│   '
        : isLast
        ? '│   └── '
        : '│   ├── ';

    final String folderLine = '$prefix ${item.company}/';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTreeLine(context, folderLine),
        _buildDetailLine(context, '$prefix│   ├── role: ${item.role}'),
        _buildDetailLine(context, '$prefix│   ├── duration: ${item.duration}'),
        if (item.type.isNotEmpty)
          _buildDetailLine(context, '$prefix│   ├── type: ${item.type}'),
        _buildDetailLine(
          context,
          '$prefix│   └── skills: ${item.skills.join(', ')}',
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTreeLine(context, '└── summary.txt'),
        _buildDetailLine(
          context,
          '    ├── total_experience: ${WorkHistory.totalExperience}+ years',
        ),
        _buildDetailLine(
          context,
          '    └── specialization: ${WorkHistory.specialization}',
        ),
      ],
    );
  }

  Widget _buildTreeLine(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        text,
        style: context.textTheme.titleLarge?.copyWith(
          fontSize: context.defaultBodyFontSize * fontScale,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildDetailLine(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        text,
        style: context.textTheme.titleLarge?.copyWith(
          fontSize: context.defaultBodyFontSize * fontScale,
          height: 1,
        ),
      ),
    );
  }
}
