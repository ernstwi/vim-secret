# vim-secret

<p align='center'>
    <img src="./example.svg">
</p>

## Usage

<table>
    <tr>
        <td><code>:Secret</code></td>
        <td>Enable secret view.</td>
    </tr>
        <td><code>:Secret (line | word | char | none)</code></td>
        <td>Enable secret view with a specific visibility setting.</td>
    <tr>
        <td><code>:Secret!</code></td>
        <td>Disable secret view.</td>
    </tr>
    <tr>
        <td><code>&lt;Plug&gt;SecretToggle</code></td>
        <td>Toggle secret view.</td>
    </tr>
</table>

An area around the cursor is unhidden to enable you to see what you are typing. This can be the entire line, the current word, the current character, or it can be disabled completely.

After a duration of time without input, or invoked manually via a mapping, all characters in the buffer is hidden. For details on this and other configuration options, see [`:help secret`](./doc/secret.txt).

## FAQ

> Replacement characters have a background color, which looks weird.

This is due to how your color scheme styles the `Conceal` highlight group. To remove the background color, you could use something like the following in your `vimrc`/`init.vim`:

```vim
autocmd! VimEnter,ColorScheme * hi Conceal ctermbg=NONE guibg=NONE
```

See [`:help secret-highlight`](./doc/secret.txt#L74) for more info.

## Testing

`make` can be used to do testing in an isolated environment. The default rule runs `test/*.vader` in Vim and Neovim.

Thanks to [vim-sneak](https://github.com/justinmk/vim-sneak) for this idea.
