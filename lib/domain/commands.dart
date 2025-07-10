enum Commands {
  clear,
  help,
  fastfetch,
  work,
  whoami,
  unknown;

  factory Commands.fromString(String command) => Commands.values.firstWhere(
    (e) => e.name == command,
    orElse: () => Commands.unknown,
  );
}
