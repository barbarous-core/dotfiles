import os
import re
import subprocess

# Get the root directory of the dotfiles repo
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
md_path = os.path.join(repo_root, 'docs/inbox_repos.md')
inbox_path = os.path.join(repo_root, 'inbox')

os.chdir(inbox_path)

with open(md_path, 'r') as f:
    for line in f:
        if '|' not in line:
            continue
        parts = [p.strip() for p in line.split('|')]
        if len(parts) < 3:
            continue
        user = parts[1]
        link_str = parts[2]
        
        match = re.search(r'\]\((https://github\.com/[^/]+/[^)]+\.git)\)', link_str)
        if not match:
            continue
        
        url = match.group(1)
        repo = url.split('/')[-1].replace('.git', '')
        
        print(f"Cloning {url} into user directory {user}...")
        
        target_dir = user
        if os.path.exists(target_dir) and os.listdir(target_dir):
            target_dir = f"{user}_{repo}"
            
        try:
            subprocess.run(['git', 'clone', url, target_dir], check=True)
        except Exception as e:
            print(f"Failed to clone {url}: {e}")
