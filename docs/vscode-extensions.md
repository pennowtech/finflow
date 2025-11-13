Following extensions can be helpful to work flawlessly:

- GitHub Actions
- GitHub Pull Requests

Awesome—let’s make VS Code auto-link your work to GitHub issues and keep your repo tidy.

## VS Code setup for above GitHub extensions to work

1. Install above _GitHub_ extension.
2. Sign in to GitHub within VS Code.
3. From an issue in the *Issues* sidebar, use **“Create Branch from Issue”**.
   VS Code will prefill a branch name with the issue number and title.
4. Optional: In VS Code Settings, adjust the extension’s **issue-branch naming template** (search settings for “GitHub Issues” and “branch”). Use a pattern like:

   ```
   feature/${issueNumber}-${sanitizedLowercaseIssueTitle}
   ```

   or

   ```
   ${issueNumber}-${sanitizedLowercaseIssueTitle}
   ```

