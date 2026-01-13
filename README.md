# ZSH environment

I was so fed up to initialize my development environments that I created this repo to automate the task.

The only thing to do is to:
- Clone this repo onto your wanted folder:

```bash
git clone git@github.com:Dr0drigues/zsh_env.git my_folder_name
```

- Create or update your `.zshrc` like this:

```bash
# Init
export ZSH_ENV_DIR="$HOME/my_folder_name"

source "$ZSH_ENV_DIR/rc.zsh"
```

And that's it.

