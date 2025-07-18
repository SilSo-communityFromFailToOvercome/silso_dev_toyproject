# **[Toy Project] Our Team's Development Guidelines**

Our goal for this project is to learn not only the technology but also "how to work together." The rules below are the minimum promises to help us stay on track.

## **1. Our Team Principles**

> Code is cold, but our collaboration must be warm.

  * **🚩 The 15-Minute Rule**
      * If you're stuck on a problem for more than 15 minutes by yourself, share it immediately in the team channel. Struggling alone is the team's biggest loss of time.
  * **🤝 Daily 5-Minute Scrum**
      * Every day at a set time, for just 5 minutes, we each share: "What I did yesterday, What I'll do today, and Any blockers." This is our time to sync up on progress and see if anyone needs help.
  * **💬 Code Has No Owner**
      * A code review is not a time to criticize a teammate. It's a process to build a better product together. Instead of asking, "Why did you write this code like this?", let's create a culture of suggesting, "Wouldn't it be better if we changed it like this?"

## **2. Git Workflow**

> We will use the **GitHub Flow**, the simplest and most intuitive strategy.

#### **🌿 Branching Strategy**

  * `main`: The final version of our code that **must always be working.** **Never push directly to this branch.**
  * `feature/feature-name`: This is where **all actual development happens.**
      * When starting a new feature, always create a new branch from `main`.
      * The branch name should clearly describe the feature in English.
          * (Good Examples) `feature/login-ui`, `feature/add-join-button`
          * (Bad Examples) `A-task`, `develop-1`

#### **✍️ Commit Rules**

> A commit message is a "development diary" for our future selves.

  * All commit messages must be written in English using the following format:
      * **`type: subject`**
      * **Main Types:**
          * `feat`: A new feature
          * `fix`: A bug fix
          * `style`: Formatting changes, missing semi-colons, etc. (no production code change)
          * `docs`: Changes to documentation
          * `refactor`: Code refactoring (improving code without changing functionality)
      * **(Examples)**
          * `feat: Add email login button to login screen`
          * `fix: Correct password validation error`

#### **🤝 Pull Request & Code Review**

1.  When your work on a `feature` branch is complete, push it to GitHub.
2.  On GitHub, create a **Pull Request (PR)** to the `main` branch.
3.  In the PR description, briefly write what you did and how to test it.
4.  At least **one other team member** (besides the author) must review the code and click **Approve**.
5.  After getting approval, the person who created the PR clicks the **Merge** button to merge the code into the `main` branch.
6.  Once merged, delete the `feature` branch you worked on.

## **3. CI/CD Rules (Automation Rules)**

> For this project, our CI/CD goal is **"Automated Mistake Prevention."**

Instead of complex Continuous Deployment (CD), we will only set up Continuous Integration (CI) to **automatically check if there are problems with our code.**

  * **Our CI Rule:** Whenever a Pull Request is created, **GitHub Actions** will automatically check the following:
    1.  If the Flutter code follows the linting rules (`flutter analyze`)
    2.  If the basic test codes pass (`flutter test`)
  * If this check fails, the code cannot be merged into the `main` branch. This is our minimum safety net to automatically prevent buggy code from being merged.

-----

#### **Attachment: `.github/workflows/ci.yml`**

> Copy the content below and create a file named `ci.yml` inside the `.github/workflows` directory in your project folder. GitHub Actions will automatically detect and run this file.

```yaml
# .github/workflows/ci.yml

name: Flutter CI

# This workflow runs whenever a Pull Request is created or updated for the main branch.
on:
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # 1. Check out the code from the repository.
      - uses: actions/checkout@v3

      # 2. Set up the Flutter environment.
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      # 3. Download Flutter dependencies.
      - run: flutter pub get

      # 4. Check if the code is formatted correctly.
      - run: flutter format --set-exit-if-changed .

      # 5. Analyze the code for errors and style issues.
      - run: flutter analyze

      # 6. Run test codes.
      # (If you don't have any tests yet, comment out this line or create a basic test that passes.)
      # - run: flutter test
```
