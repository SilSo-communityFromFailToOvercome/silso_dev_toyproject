Of course. Here is the complete `README.md` file for your project, translated into English and formatted for Notion.

-----

# **TOY PROJECT: Hatching the Egg of Failure**

## **1. Project Overview**

  * **Project:** A mini-app where users 'hatch' and 'grow' an egg by recording their failures. Each record gives the egg experience points (EXP), and it evolves visually when it reaches certain milestones.
  * **Goal:** To experience the core MVP development cycle (authentication, data creation/retrieval, UI updates) with Flutter and Firebase within 10 days and to establish a team collaboration process.
  * **Timeline:** July 18, 2025 (Fri) \~ July 27, 2025 (Sun) / 10 days
  * **Tech Stack:** `Flutter`, `Firebase (Authentication, Firestore)`, `Git/GitHub`, `Rive (Optional)`

-----

## **2. Team Roles & Responsibilities**

| Role | Member | Mission |
| :--- | :--- | :--- |
| 🎨 **UI/UX Authority Designer** | **Kwak-Kwak** | To take full responsibility for all visual elements, creating the "fun of growing" by visually implementing the egg's evolution. |
| 🔐 **Access Control System Designer** | **yeye** | To build the system's backbone by defining the egg's growth rules and data, ensuring it is stored and managed securely. |
| 🔗 **Feature & State Integration Lead**| **Jang-Jang**| To achieve "completion" by connecting the UI and the system, ensuring user actions translate into actual changes in the app. |

-----

## **3. Rules & Workflow**

> The rules below are the minimum promises to help us stay on track.

### **🤝 Our Principles**

  * **The 15-Minute Rule:** If you're stuck on a problem for more than 15 minutes, share it with the team immediately.
  * **Daily Scrum:** Every morning, we share "what I did yesterday, what I'll do today, and any blockers" for 5 minutes.
  * **Code Review:** A code review is a process to build a better product together, not to criticize a teammate.

### **🌿 Git Workflow**

  * **Strategy:** We follow the simple **GitHub Flow**, using only a `main` branch and `feature/feature-name` branches.
  * **Commit Rule:** Use the format `type: subject` (e.g., `feat: Add login button`).
  * **Merge Method:** All code is merged into the `main` branch only through a **Pull Request (PR)**. A PR must be **Approved** by at least one other team member before merging.

### **🛠️ Step-by-Step Git Guide**

> **We do not use `Fork`.** Follow the steps below to work with `branches`.

1.  **Starting New Work:** (Get your local machine up to date)
    ```bash
    git checkout main
    git pull origin main
    git checkout -b feature/your-feature-name
    ```
2.  **Saving & Sharing Your Work:** (Push your work to GitHub)
    ```bash
    git add .
    git commit -m "feat: Commit message"
    git push origin feature/your-feature-name
    ```
3.  **Finishing Your Work:** (Create a Pull Request on GitHub and Merge)
      * Go to the GitHub repository page, create a `Pull Request`, get it reviewed by your team, and then `Merge`.

### **🤖 CI (Continuous Integration)**

  * Whenever a Pull Request is created, GitHub Actions will automatically check the code style and syntax to prevent problematic code from being merged into `main`.

-----

## **4. 10-Day Sprint Plan**

| Day | Date | **Daily Team Goal** | 🎨 **Kwak-Kwak (UI/UX)** | 🔐 **yeye (System)** | 🔗 **Jang-Jang (Integration)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1**| Fri | **Kick-off & Design** | Design UI/UX concepts & egg evolution stages. | Draft the data model. | Finalize project goals & schedule. |
| **2**| Sat | **Setup & Foundation** | Prepare image/animation assets for each egg state. | Finalize data model & create Firestore structure. | Set up Flutter project & Firebase integration. |
| **3**| Sun | **Implement Auth** | Implement Login/Sign-up screen UI. | Write security rules for User data. | Implement email authentication logic. |
| **4**| Mon | **Implement Main Screen** | Implement the main screen UI to display the egg's current state. | Design DB structure for the Egg (EXP, state). | Implement logic to navigate to the main screen after login. |
| **5**| Tue | **'Record Failure' Feature**| Implement the input screen UI (Modal/Page) for recording failures. | Design the logic for increasing EXP when a failure is recorded. | Implement the "Write" button and the input screen functionality. |
| **6**| Wed | **Connect Core Logic** | Implement UI logic to show different egg images based on EXP. | Write rules to change 'growth state' based on EXP. | **(Integrate)** Connect the "Write" action to call yeye's logic and update the DB. |
| **7**| Thu | **Visualize Growth** | **(Integrate)** Connect the UI so the egg image actually changes based on the 'growth state' from the DB. | Support C-Team with necessary queries and testing. | **(Integrate)** Fetch the egg's current state and EXP from the DB in real-time and reflect it on the screen. |
| **8**| Fri | **Integration & Code Review**| **(All)** Conduct full-feature integration testing (Sign-up -\> Record -\> Grow) and a team code review. | **(All)** Conduct full-feature integration testing and a team code review. | **(All)** Conduct full-feature integration testing and a team code review. |
| **9**| Sat | **Deploy & Polish**| Polish the overall app design and improve animations. | Check for data stability, set initial values, etc. | Deploy the final product as a web app using Firebase Hosting. |
| **10**| Sun | **Retrospective & Next Steps**| **(All)** Hold a project retrospective (KPT: Keep, Problem, Try) and document lessons learned for the real MVP. | **(All)** Hold a project retrospective and document lessons learned. | **(All)** Hold a project retrospective and document lessons learned. |