# ft-mapper.nvim

A Neovim plugin that enhances `f`, `F`, `t`, and `T` motions to search for multiple character variants with a single keystroke. Perfect for multilingual environments where you want to search for both half-width and full-width characters seamlessly.

## ✨ Features

- **Multi-character search**: Search for multiple character variants with a single keystroke
- **Full-width/Half-width support**: Seamlessly handle Japanese, Chinese, and other full-width characters
- **Preserves native behavior**: Falls back to default Vim behavior for unmapped characters
- **Repeat support**: Works with `;` and `,` for repeating searches
- **Count support**: Compatible with count prefixes (e.g., `3f,`)
- **All modes supported**: Works in Normal, Visual, and Operator-pending modes

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/ft-mapper.nvim",
  config = function()
    require("ft-mapper").setup({
      mappings = {
        -- Search for both half-width and full-width commas
        { ",", "、", "，" },
        -- Search for both half-width and full-width periods  
        { ".", "。", "．" },
        -- Search for both half-width and full-width colons
        { ":", "：" },
        -- Add more mappings as needed
      }
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/ft-mapper.nvim",
  config = function()
    require("ft-mapper").setup({
      mappings = {
        { ",", "、", "，" },
        { ".", "。", "．" },
        { ":", "：" },
      }
    })
  end
}
```

## ⚙️ Configuration

The plugin requires a `mappings` table where each entry is an array:
- First element: The character you type
- Remaining elements: Additional characters to search for

```lua
require("ft-mapper").setup({
  mappings = {
    -- When you type 'f,' it will find ',', '、', or '，'
    { ",", "、", "，" },
    { ".", "。", "．" },
    { ":", "：" },
    { ";", "；" },
    { "!", "！" },
    { "?", "？" },
    { "(", "（" },
    { ")", "）" },
    { "[", "「", "『", "【", "［" },
    { "]", "」", "』", "】", "］" },
    { "'", "'", "'" },
    { '"', """, """, "«", "»" },
    { "-", "ー", "―", "—", "–" },
    { " ", "　" }, -- half-width and full-width spaces
  },
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
- `f,` from the beginning jumps to any of the commas
- `F。` from the end jumps backward to any of the periods

### Mixed Language Documents
```
Hello, world! こんにちは、世界！
```
- `f!` finds both `!` and `！`
- `f,` finds both `,` and `、`

### Code Comments with Full-width Characters
```python
# 設定ファイルを読み込む。エラーの場合、デフォルト値を使用。
if not config:
    return default_config  # 失敗：設定なし
```

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
```

## 📋 Requirements

- Neovim 0.7.0 or higher
- No external dependencies

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Inspired by the need for better multilingual text navigation in Neovim, especially for developers working with Japanese, Chinese, and other languages that use full-width characters.
