# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-01-15

### Added
- Initial release of lambda-layers-builder module
- Support for layer compilation via custom scripts
- Support for layer compilation via direct commands
- Automatic ZIP file generation with integrity hashes
- Consistent naming convention following corporate standards
- Comprehensive validation for input parameters
- Integration outputs for lambda-layers deployment module
- Support for multiple runtimes (Python, Node.js, etc.)
- Build information outputs for debugging and validation

### Features
- **Script-based compilation**: Execute custom build scripts for complex layer requirements
- **Command-based compilation**: Direct command execution ideal for Backstage integration
- **Automatic archiving**: Generate optimized ZIP files with calculated hashes
- **Multi-layer support**: Build multiple layers in a single module call
- **Corporate compliance**: Consistent naming and tagging strategy
- **CI/CD ready**: Optimized for automated pipeline integration

### Documentation
- Complete README with usage examples
- API documentation for all variables and outputs
- Integration examples with lambda-layers module
- Troubleshooting guide and best practices
- Sample scripts for common runtimes

### Examples
- Basic layer compilation example
- Python layer with pip dependencies
- Node.js layer with npm packages
- Multi-layer build configuration
- Integration with deployment module