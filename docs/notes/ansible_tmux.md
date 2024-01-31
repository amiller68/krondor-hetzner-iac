# Ansible Tmux Pattern

tmux is a useful tool for emulating terminal sessions.
This is really handy when you want to run detached processes in an ansible playbook.
Here's an example for launching a long running benchmark.

```
- name: Run the benchmark
shell: "tmux new -d '
    ./bench.sh \
    {{ input_path }} \ 
    tmux wait -S bench;'"

- debug:
    msg: "
    Waiting for the benchmark to finish.
    Feel free to exit this playbook.
    You can check the status of your job by connecting to your user and running `tmux a`.
    "

- name: Wait for the benchmark to finish
shell: "tmux wait bench"
ignore_errors: yes
```