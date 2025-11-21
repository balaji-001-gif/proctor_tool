# Proctor Tool

A lightweight proctoring integration for Frappe LMS.

## Features

- **Seamless Integration**: Directly integrates with Frappe LMS Quizzes.
- **Session Tracking**: Monitors quiz sessions for integrity.
- **Automated Events**: Hooks into Quiz Submission events (`after_insert`, `on_submit`) to manage proctoring sessions automatically.
- **Custom Interface**: Injects custom JavaScript (`proctor_quiz.js`) for the proctoring interface.

## Installation

1.  Get the app from GitHub:

    ```bash
    bench get-app https://github.com/balaji-001-gif/Proctortool-BK.git
    ```

2.  Install the app on your site:

    ```bash
    bench --site [your-site-name] install-app proctor_tool
    ```

3.  Migrate the database:

    ```bash
    bench --site [your-site-name] migrate
    ```

## Usage

Once installed, the Proctor Tool automatically hooks into the LMS Quiz submission process.

-   **Configuration**: Ensure the app is installed and active.
-   **Operation**: When a student starts a quiz, the proctoring session is initialized. Upon submission, the session is finalized.

## License

MIT
