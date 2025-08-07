# Lint Rules

Shared lint rules package for the monorepo workspace.

## Features

- 🔍 **Consistent Code Style**: Enforces uniform coding standards across all packages
- 📏 **Workspace Standards**: Shared lint rules for the entire monorepo
- ⚡ **Easy Integration**: Simple setup with workspace resolution
- 🎯 **Flutter Optimized**: Tailored rules for Flutter development
- 🔧 **Customizable**: Extendable rules based on project needs

## Installation

This package is part of the workspace and uses workspace resolution:

```yaml
dev_dependencies:
  lint_rules:
    path: ../lint_rules
```

## Usage

### Basic Setup

Create an `analysis_options.yaml` file in your package root:

```yaml
include: package:lint_rules/analysis_options.yaml
```

### Custom Configuration

You can extend the base rules with package-specific customizations:

```yaml
include: package:lint_rules/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    # Add package-specific rules
    prefer_const_constructors: true
    # Override workspace rules if needed
    lines_longer_than_80_chars: false
```

### Integration with IDE

Most IDEs will automatically pick up the `analysis_options.yaml` file and provide:

- **Real-time linting**: Immediate feedback as you type
- **Quick fixes**: Automated code corrections
- **Format on save**: Automatic code formatting
- **Error highlighting**: Visual indicators for lint violations

## Configuration

### Workspace-wide Rules

The base `analysis_options.yaml` includes:

- **Dart language rules**: Core Dart linting rules
- **Flutter-specific rules**: Flutter best practices
- **Performance rules**: Code optimization guidelines
- **Style consistency**: Formatting and naming conventions
- **Error prevention**: Rules to catch common mistakes

### Excluded Files

By default, the following files are excluded from linting:

- Generated files (`*.g.dart`)
- Freezed files (`*.freezed.dart`)
- Build artifacts
- Test mocks (when applicable)

## Examples

### Package Structure

```
your_package/
├── lib/
│   ├── src/
│   │   └── your_code.dart
│   └── your_package.dart
├── test/
│   └── your_test.dart
├── analysis_options.yaml  # ← Includes lint_rules
└── pubspec.yaml
```

### Sample analysis_options.yaml

```yaml
include: package:lint_rules/analysis_options.yaml

analyzer:
  exclude:
    - "lib/generated/**"
  
  language:
    strict-casts: true
    strict-inference: true

linter:
  rules:
    # Package-specific overrides
    public_member_api_docs: false  # For internal packages
    lines_longer_than_80_chars: false  # Allow longer lines
```

### CI/CD Integration

Add linting to your workflow:

```yaml
# .github/workflows/ci.yml
- name: Analyze code
  run: melos run analyze
```

Or run directly:

```bash
# Analyze all packages
melos exec -- "dart analyze . --fatal-infos"

# Analyze specific package
cd packages/your_package
dart analyze . --fatal-infos
```

## Available Scripts

If you're using the workspace's melos configuration:

```bash
# Run analysis on all packages
melos run analyze

# Format code in all packages
melos run format

# Check for formatting issues
melos run format --set-exit-if-changed
```

## Customization

### Adding New Rules

To add workspace-wide rules, modify `analysis_options.yaml` in the `lint_rules` package:

```yaml
linter:
  rules:
    # Add new rules here
    your_new_rule: true
```

### Package-Specific Rules

For package-specific rules, override in the individual package's `analysis_options.yaml`:

```yaml
include: package:lint_rules/analysis_options.yaml

linter:
  rules:
    # Package-specific rules
    prefer_final_fields: true
    # Disable workspace rule for this package
    some_workspace_rule: false
```

## Best Practices

### Code Style

- Use consistent naming conventions
- Prefer `const` constructors when possible
- Document public APIs
- Keep functions and classes focused
- Use meaningful variable names

### Performance

- Avoid unnecessary widget rebuilds
- Use `const` widgets when possible
- Prefer `final` over `var` when applicable
- Profile performance-critical code

### Maintainability

- Write self-documenting code
- Add comments for complex business logic
- Keep functions small and focused
- Use type annotations consistently

## Troubleshooting

### Common Issues

**Lint rule conflicts:**
```yaml
# Disable conflicting rules in your analysis_options.yaml
linter:
  rules:
    conflicting_rule: false
```

**IDE not recognizing rules:**
- Restart your IDE
- Check that `analysis_options.yaml` is in the correct location
- Ensure the `lint_rules` package path is correct

**False positives:**
```yaml
# Use ignore comments for specific cases
// ignore: rule_name
your_code_here();

// Or ignore entire files
// ignore_for_file: rule_name
```

## Development

### Running Analysis

```bash
dart analyze
```

### Updating Rules

When modifying the base rules:

1. Test changes across multiple packages
2. Document breaking changes
3. Update this README if needed
4. Run full workspace analysis to ensure compatibility

## Contributing

This is a workspace package. Please ensure:

- New rules benefit the entire workspace
- Breaking changes are discussed with the team
- Documentation is updated accordingly
- All packages continue to pass analysis

## License

This project is part of a private workspace and is not published to pub.dev.