# Local Dependency Analysis Setup

This document outlines the setup and usage of the
`com.autonomousapps.dependency-analysis` Gradle plugin to enforce a strict
dependency management policy.

## Objective

The primary goal is to ensure that all dependencies are explicitly declared and
directly used. This means the project should satisfy the following conditions:

1.  **No Unused Dependencies**: A dependency is listed in a `build.gradle.kts`
    file _only if_ it is directly used by the source code (Kotlin, XML, etc.)
    within that module.
2.  **No Implicit Transitive Dependencies**: If the code uses a library that is
    brought in as a transitive dependency of another library, it must be
    explicitly declared as a direct dependency.

This practice leads to a cleaner, more understandable, and more maintainable
build configuration.

## Plugin Setup

The project uses the `com.autonomousapps.dependency-analysis` plugin, version
`3.4.1`.

### 1. Add Plugin to Version Catalog

First, define the plugin and its version in `gradle/libs.versions.toml`.

```toml
# gradle/libs.versions.toml

[versions]
# ... other versions
dependencyAnalysis = "3.4.1"

[plugins]
# ... other plugins
dependency-analysis = { id = "com.autonomousapps.dependency-analysis", version.ref = "dependencyAnalysis" }
```

### 2. Apply Plugin in Build Files

Next, apply the plugin to the root project and the specific modules you want to
analyze.

**Root Project (`build.gradle.kts`)**

Apply the plugin to the root project so it can be used by subprojects.

```kotlin
// build.gradle.kts

plugins {
    // ... other plugins
    alias(libs.plugins.dependency.analysis)
}
```

**Module (`mobile/build.gradle.kts` or `wear/build.gradle.kts`)**

Apply the plugin within each module that needs to be analyzed.

```kotlin
// mobile/build.gradle.kts

plugins {
    // ... other plugins
    alias(libs.plugins.dependency.analysis)
}
```

## Verification Process

After setup, you can use the plugin to verify that the dependency objective is
met.

### 1. Running the Analysis

The primary task to run is `buildHealth`. This task analyzes all modules where
the plugin is applied.

```bash
./gradlew buildHealth
```

After the task completes, it will generate a report. If there are any dependency
violations (unused, transitive, etc.), they will be listed in:
`build/reports/dependency-analysis/build-health-report.txt`

If this report is empty, the project's dependencies are correctly configured
according to our objective.

### 2. Verifying the Analyzer is Working Correctly

To ensure the plugin is active and correctly identifying issues, you can perform
a quick sanity check:

1.  **Introduce an unused dependency**: Add a known-unused library to any
    module's `build.gradle.kts`.
    ```kotlin
    dependencies {
        implementation("org.mockito:mockito-core:5.12.0") // A temporarily added, unused dependency
        // ... other dependencies
    }
    ```
2.  **Run the analyzer**: Execute `./gradlew buildHealth`.
3.  **Check the report**: The `build-health-report.txt` file should now list the
    Mockito dependency as unused.
4.  **Revert the change**: Remove the temporary dependency.

### 3. Verifying Indirect Dependencies

The static analysis plugin is powerful but not infallible. It may not always
detect indirect usage, such as dependencies used only in themes
(`styles.xml`/`themes.xml`) rather than in code or layouts.

If you suspect a dependency reported as "used" is actually not, you can verify
it with a build test:

1.  **Temporarily remove the dependency** from the `build.gradle.kts` file.
2.  **Run a clean build**:
    ```bash
    ./gradlew clean build
    ```
3.  **Observe the result**:
    - If the **build fails**, it confirms the dependency is necessary, even if
      for indirect reasons like a theme. You should restore the dependency.
    - If the **build succeeds**, the dependency is likely unused and can be
      safely removed.

This manual check serves as a final confirmation that all listed dependencies
are truly required for the project to compile and run.
