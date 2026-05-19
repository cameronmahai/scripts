import os
import subprocess
import shutil

class Lesson:
    def __init__(self, title, instruction, validation_fn, success_message):
        self.title = title
        self.instruction = instruction
        self.validation_fn = validation_fn
        self.success_message = success_message

def check_git_init(sandbox_path):
    return os.path.isdir(os.path.join(sandbox_path, '.git'))

def check_first_commit(sandbox_path):
    git_dir = os.path.join(sandbox_path, '.git')
    if not os.path.isdir(git_dir):
        return False
    try:
        # Check if there is at least one commit
        result = subprocess.run(
            ['git', 'rev-parse', 'HEAD'],
            cwd=sandbox_path,
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except Exception:
        return False

def check_remote_added(sandbox_path):
    try:
        result = subprocess.run(
            ['git', 'remote', '-v'],
            cwd=sandbox_path,
            capture_output=True,
            text=True
        )
        return 'origin' in result.stdout
    except Exception:
        return False

def check_pull_simulation(sandbox_path):
    # Simulate pull by checking if origin/main exists or if a specific file was "pulled"
    # For this simulation, we'll check if they tried to run 'git pull origin main'
    # Actually, let's just check if they added another file as if it was pulled.
    return os.path.exists(os.path.join(sandbox_path, 'remote_update.txt'))

def check_branch_created(sandbox_path):
    try:
        result = subprocess.run(
            ['git', 'branch'],
            cwd=sandbox_path,
            capture_output=True,
            text=True
        )
        return 'feature-branch' in result.stdout
    except Exception:
        return False

lessons = [
    Lesson(
        "1. The Repository (git init)",
        "The first step in any Git project is creating a repository.\n"
        "Go to the 'github_tutor/sandbox' directory in another terminal (or use 'cd github_tutor/sandbox')\n"
        "and run: git init",
        check_git_init,
        "Great! You've initialized your first Git repository. The .git folder now tracks your changes."
    ),
    Lesson(
        "2. Your First Commit",
        "Now, let's save some work. Create a file named 'hello.txt', add it, and commit it.\n"
        "Run:\n"
        "  echo 'Hello GitHub' > hello.txt\n"
        "  git add hello.txt\n"
        "  git commit -m 'Initial commit'",
        check_first_commit,
        "Success! You've created a snapshot of your project. This is 'local' version control."
    ),
    Lesson(
        "3. Adding a Remote",
        "GitHub acts as a 'remote' server for your code.\n"
        "In a real scenario, you'd use a URL from GitHub. For this tutor, we'll simulate it.\n"
        "Run:\n"
        "  git remote add origin https://github.com/your-username/my-repo.git\n"
        "(Don't worry, we won't actually connect to the internet yet!)",
        check_remote_added,
        "Nice! You've linked your local repo to a (theoretical) remote server."
    ),
    Lesson(
        "4. Branching",
        "Branches allow you to work on new features without breaking the main code.\n"
        "Create a new branch called 'feature-branch'.\n"
        "Run:\n"
        "  git checkout -b feature-branch",
        check_branch_created,
        "Perfect! You're now on a separate branch, safe to experiment."
    ),
    Lesson(
        "5. Pulling Updates",
        "On GitHub, others might update the code. You need to 'pull' those changes.\n"
        "Let's simulate a pull. Imagine someone added 'remote_update.txt' to the server.\n"
        "To pass this, create that file yourself as if it was downloaded:\n"
        "  touch remote_update.txt",
        check_pull_simulation,
        "Got it! Pulling keeps your local copy in sync with the team."
    )
]
