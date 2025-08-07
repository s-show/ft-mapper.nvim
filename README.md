# ft-mapper.nvim

A Neovim plugin that extends `f`, `F`, `t`, and `T` motions to search for multiple character variants with a single keystroke. Perfect for multilingual environments where half-width and full-width characters are mixed.

## ✨ Features

- **Multi-character search**: Search for multiple character variants with a single keystroke (e.g., `f,` jumps to `,`, `、`, or `，`)
- **Full-width/Half-width support**: Seamlessly handle Japanese, Chinese, and other full-width characters
- **Preserves native behavior**: Falls back to default Vim behavior for unmapped characters
- **Repeat support**: Works with `;` and `,` for repeating searches
- **Count support**: Compatible with count prefixes (e.g., `3f,`)
- **All modes supported**: Works in Normal, Visual, and Operator-pending modes
- **Replace `;`, `,`**: Ability to change `;` and `,` command keys to any other keys

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

Here's the configuration for [lazy.nvim](https://github.com/folke/lazy.nvim). No default mappings are provided, so `mappings` must be configured.

```lua
{
  "your-username/ft-mapper.nvim",
  config = function()
    require("ft-mapper").setup({
      mappings = {
        { ",", "、", "，" },
        { ".", "。", "．" },
        { ":", "：" },
        { "[", "「", "『", "【", "［" },
        { "]", "」", "』", "】", "］" },
        -- Add more mappings as needed
      }
    })
  end
}
```

## ⚙️ Configuration

### Configuration Options

- `mappings (string[][])`
    - Configure the key combinations for `f` or `t` and the characters you want to search for.
    - Example: { ",", "、", "，" }
    - First element: The character to type with `f` or `t` (like `,` in `f,`)
    - Remaining elements: Characters to search for when typing `f,`
- `replace_semicolon (string)` (optional)
    - Set if you want to execute repeat search with `;` using a different key.
- `replace_comma (string)` (optional)
    - Set if you want to execute reverse repeat search with `,` using a different key.
- `debug (boolean)` (optional)
    - Enable debug output for troubleshooting. Should normally be `false`. Default value is `false`.

```lua
require("ft-mapper").setup({
  mappings = {
    -- This configuration is designed with Japanese in mind.
    { ',', '、', '，' },
    { '.', '。', '．' },
    { ":", "：" },
    { ";", "；" },
    { "!", "！" },
    { "?", "？" },
    { "(", "（" },
    { ")", "）" },
    { "[", "「", "『", "【", "［" },
    { "]", "」", "』", "】", "］" },
    { "'", "'", "'" },
    { '"', "“", "”", "゛" },
    { '<', "＜", "«" },
    { '>', "＞", "»" },
    { "-", "ー", "―", "—", "–" },
    { " ", "　" }, -- half-width and full-width spaces
  },
  -- Use `:` instead of `>` for repeat search (optional)
  replace_semicolon = '>',
  -- Use `<` instead of `,` for reverse repeat search (optional)
  replace_comma = '<',
  -- Enable debug output (optional)
  debug = false
})
```

## 🚀 Usage

Once configured, simply use the `f`, `F`, `t`, and `T` motions as you normally would:

- `f,` - Jump forward to the next `,`, `、`, or `，`
- `F,` - Jump backward to the previous `,`, `、`, or `，`
- `t,` - Jump forward to just before the next `,`, `、`, or `，`
- `T,` - Jump backward to just after the previous `,`, `、`, or `，`

Repeat motions work as expected:
- `;` - Repeat the last search in the same direction
- `,` - Repeat the last search in the opposite direction

Count prefixes are supported:
- `3f,` - Jump to the 3rd occurrence of `,`, `、`, or `，`

## 🔍 Example Use Cases

### Japanese Text
```
これは、テストです。次の文、そして最後の文。
```
- Jump to any comma with `f,` from the beginning
- Jump backward to any period with `F。` from the end

### Multilingual Mixed Documents
```
Hello, world! こんにちは、世界！
```
- Search for both `!` and `！` with `f!`
- Search for both `,` and `、` with `f,`

### Demo Videos

[demo_without_operator.webm](https://github.com/user-attachments/assets/3d070a72-ea37-41a2-b72f-4b805f999c14)

[demo_with_operator.webm](https://github.com/user-attachments/assets/081f6e68-33d8-4b88-9575-9d6b6501f7a0)

## 🛠️ Advanced Features

### Debug Mode

Enable debug output to troubleshoot mappings:

```lua
require("ft-mapper").setup({
  mappings = { --[[ your mappings ]] },
  debug = true
})
```

### Checking Current Configuration

```vim
:lua require("ft-mapper").show_config()
" or
:= require("ft-mapper").show_config()
```

## 📋 Requirements

- Neovim 0.7.0 or higher
- No external dependencies

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Original Plugin

This plugin is a Lua rewrite and extension of [juro106/ftjpn](https://github.com/juro106/ftjpn), which I used daily.

Thanks to [juro106/ftjpn](https://github.com/juro106/ftjpn) for creating a plugin that improves the efficiency of editing Japanese documents.

## FAQ

### Q: Why do I need this plugin?

A: In documents mixing Japanese and English, punctuation marks often appear in both half-width (,) and full-width (、) forms. While the normal `f,` only searches for half-width commas, this plugin allows you to search for both.

### Q: Can I add custom mappings?

A: Simply add new entries to the `mappings` table. The first element is the input character, and the rest are the search target characters.
