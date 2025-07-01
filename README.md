# PHPUnit Progress

A beautiful, real-time progress wrapper for PHPUnit and ParaTest that transforms your test output into a modern, visually appealing experience.

## ✨ Features

- **Real-time Progress Bar**: Visual progress indicator showing test completion percentage
- **Beautiful Output**: Enhanced colors, Unicode symbols, and modern formatting
- **Dual Runner Support**: Works with both ParaTest (parallel) and PHPUnit (single-process)
- **Smart Failure Reporting**: Clear, organized display of test failures and errors
- **Execution Timing**: Shows formatted execution time (seconds, minutes, hours)
- **Status Summary**: Comprehensive test results with pass/fail counts
- **Clean Interface**: Organized output with dividers and structured information

## 🎯 Demo

### ✅ Success Output
```
❯ ./phpunit.sh
 [██████████████████████████████████████████████████] 100% ✓ 1044 of 1044

✓ All tests passed 

✓ OK (1044 tests, 1896 assertions)

────────────────────────────────────────────────────────────
✓ Success! All tests completed successfully in 7.0s
────────────────────────────────────────────────────────────
```

### ❌ Failure Output
```
❯ ./phpunit.sh
 [██████████████████████████████████████████████████] 100% ✓ 1043 ✗ 1 of 1044

✗ Tests failed
  Passed: 1043
  Failed: 1

⚠ Detailed failure information:

│  There was 1 failure:
1) AppTest\Error\ApiClientProblemTest::testCreateWithHttpStatusCode
├─ Failed asserting that 403 is identical to 404.
│  /Users/tim.alexander/mw/test/Error/ApiClientProblemTest.php:31
│  FAILURES!

────────────────────────────────────────────────────────────
✗ Testing completed with 1 failure(s) in 7.0s
────────────────────────────────────────────────────────────
```

## 📋 Requirements

- **Bash**: Compatible shell environment
- **PHPUnit**: For single-process testing
- **ParaTest**: For parallel testing (recommended)
- **Unix-like OS**: macOS, Linux, or WSL

## 🚀 Installation

1. **Download the script**:
   ```bash
   curl -o phpunit.sh https://raw.githubusercontent.com/TimAnthonyAlexander/phpunit-progress/main/phpunit.sh
   chmod +x phpunit.sh
   ```

2. **Or clone the repository**:
   ```bash
   git clone https://github.com/TimAnthonyAlexander/phpunit-progress.git
   cd phpunit-progress
   chmod +x phpunit.sh
   ```

## ⚙️ Configuration

Edit the `TEST_CMD` variable in `phpunit.sh` to match your setup:

### ParaTest (Parallel Testing - Default)
```bash
TEST_CMD=(vendor/bin/paratest --colors=never --functional)
```

### PHPUnit (Single Process)
```bash
TEST_CMD=(vendor/bin/phpunit --colors=never)
```

### Custom Runner
```bash
TEST_CMD=(path/to/custom-runner <options>)
```

**Important**: Keep exactly one `TEST_CMD` assignment active by commenting out the others.

## 🎮 Usage

### Basic Usage
```bash
./phpunit.sh
```

### With Additional Arguments
```bash
./phpunit.sh --filter=MyTestClass
./phpunit.sh --group=integration
./phpunit.sh tests/Unit/
```

### Integration Examples

#### As Git Hook
```bash
# Copy to your git hooks directory
cp phpunit.sh .git/hooks/pre-push
```

#### In CI/CD Pipeline
```yaml
# GitHub Actions example
- name: Run Tests with Progress
  run: ./phpunit.sh
```

#### As NPM Script
```json
{
  "scripts": {
    "test": "./phpunit.sh",
    "test:filter": "./phpunit.sh --filter"
  }
}
```

## 🎨 Visual Elements

The script uses various visual elements for enhanced readability:

- **Progress Bar**: `█` for completed tests, `░` for remaining
- **Status Icons**: `✓` success, `✗` failure, `⚠` warning, `ℹ` info
- **Color Coding**: 
  - 🟢 Green: Passed tests and success messages
  - 🔴 Red: Failed tests and error messages
  - 🟡 Yellow: Warnings and intermediate progress
  - 🔵 Blue/Cyan: Information and progress indicators

## 🔧 Customization

### Adjusting Progress Bar Width
```bash
# Change the BAR_WIDTH variable (default: 50)
BAR_WIDTH=80
```

### Modifying Colors
Edit the color variables at the top of the script:
```bash
green=$'\033[0;32m'
red=$'\033[0;31m'
yellow=$'\033[1;33m'
# ... etc
```

## 🐛 Troubleshooting

### Common Issues

**Script doesn't execute**
```bash
chmod +x phpunit.sh
```

**No progress shown**
- Ensure your test runner outputs progress in the expected format
- Check that `--colors=never` is included in your TEST_CMD

**Incomplete progress bar**
- The script parses output patterns like "488 / 1227 ( 39%)"
- Verify your test runner produces compatible output

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for PHP projects using PHPUnit and ParaTest
- Inspired by modern CLI tools and progress indicators
- Designed for developer productivity and visual clarity

---

**Made with ❤️ for the PHP testing community** 