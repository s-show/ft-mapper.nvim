-- ft-mapper.lua
-- マルチバイト文字を半角文字で検索できるようにするNeovimプラグイン

local M = {}

-- 設定（初期値は空）
M.config = {}
M.is_setup = false

-- 状態を保存
M.last_search = {
  command = nil,
  char = nil,
  chars = nil,
  last_target_index = nil, -- 最後に移動した位置を記録
  last_position = nil -- 最後のカーソル位置を記録
}

-- 文字マッピングテーブルを構築
local function build_mapping_table(mappings)
  local lookup = {}
  for _, mapping in ipairs(mappings) do
    local key = mapping[1]
    local targets = {}
    for i = 2, #mapping do
      table.insert(targets, mapping[i])
    end
    lookup[key] = targets
  end
  return lookup
end

-- カーソル位置を取得
local function get_cursor_pos()
  local pos = vim.api.nvim_win_get_cursor(0)
  return pos[1], pos[2]
end

-- カーソル位置を設定
local function set_cursor_pos(line, col)
  vim.api.nvim_win_set_cursor(0, { line, col })
end

-- 現在の行を取得
local function get_current_line()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  return vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
end

-- 文字列のバイト位置から文字位置を計算（0ベース）
local function byte_to_char_index(str, byte_pos)
  local byte_count = 0

  for i = 1, vim.fn.strchars(str) do
    if byte_count == byte_pos then
      return i - 1 -- 0ベースのインデックスを返す
    end

    local char = vim.fn.strcharpart(str, i - 1, 1)
    byte_count = byte_count + #char

    if byte_count > byte_pos then
      -- カーソルがマルチバイト文字の途中にある場合
      return i - 1 -- その文字の位置を返す
    end
  end

  return vim.fn.strchars(str) - 1
end

-- 文字位置からバイト位置を計算（0ベース）
local function char_index_to_byte(str, char_index)
  if char_index < 0 then
    return 0
  end

  local byte_pos = 0
  local max_chars = vim.fn.strchars(str)

  for i = 0, math.min(char_index - 1, max_chars - 1) do
    local char = vim.fn.strcharpart(str, i, 1)
    byte_pos = byte_pos + #char
  end

  return byte_pos
end

-- 検索を実行
local function do_search(command, char, count, search_chars, is_repeat)
  local line = get_current_line()
  local line_num, byte_col = get_cursor_pos()

  -- 文字単位での位置を計算（0ベース）
  local char_index = byte_to_char_index(line, byte_col)

  -- 同じコマンドが前回と同じ位置で実行されたかチェック
  local is_same_position = false
  if M.last_search.command == command and 
     M.last_search.char == char and
     M.last_search.last_position and
     M.last_search.last_position[1] == line_num and
     M.last_search.last_position[2] == byte_col then
    is_same_position = true
  end

  if M.config.debug then
    print(string.format("=== Search Debug ==="))
    print(string.format("Command: %s, Char: %s, Count: %d, Repeat: %s, Same Position: %s", 
      command, char, count, tostring(is_repeat), tostring(is_same_position)))
    print(string.format("Line: %s", line))
    print(string.format("Current byte col: %d, char index: %d", byte_col, char_index))
    print("Search chars: " .. vim.inspect(search_chars))
    -- 現在のカーソル位置の文字を表示
    local current_char = vim.fn.strcharpart(line, char_index, 1)
    print(string.format("Current char at index %d: '%s' (bytes: %d)", char_index, current_char, #current_char))
  end

  -- 文字が検索対象かチェックする関数
  local function is_target_char(c)
    for _, target in ipairs(search_chars) do
      if c == target then
        return true
      end
    end
    return false
  end

  -- 検索方向に応じて処理
  local found_count = 0
  local target_index = nil
  local line_length = vim.fn.strchars(line)

  if command == 'f' then
    -- 前方検索
    -- 同じコマンドの繰り返しで、前回と同じ位置にいる場合は、次の文字から検索
    local start_index = char_index + 1
    if (is_repeat or is_same_position) and M.last_search.last_target_index == char_index then
      -- 現在の文字を飛ばす（既に次の文字から始まっているので変更なし）
      start_index = char_index + 1
    end

    for i = start_index, line_length - 1 do
      local c = vim.fn.strcharpart(line, i, 1)
      if M.config.debug then
        print(string.format("f: Checking index %d: '%s'", i, c))
      end
      if is_target_char(c) then
        found_count = found_count + 1
        if found_count == count then
          target_index = i
          break
        end
      end
    end
  elseif command == 'F' then
    -- 後方検索
    -- 同じコマンドの繰り返しで、前回と同じ位置にいる場合は、現在位置の前から検索
    local start_index = char_index
    if (is_repeat or is_same_position) and M.last_search.last_target_index == char_index then
      -- 現在の文字を飛ばす
      start_index = char_index - 1
    end

    if start_index >= 0 then
      for i = start_index, 0, -1 do
        local c = vim.fn.strcharpart(line, i, 1)
        if M.config.debug then
          print(string.format("F: Checking index %d: '%s'", i, c))
        end
        if is_target_char(c) then
          found_count = found_count + 1
          if found_count == count then
            target_index = i
            break
          end
        end
      end
    end
  elseif command == 't' then
    -- 前方検索（文字の手前まで）
    -- 現在位置の2つ先から検索を開始（次の文字の次から）
    local start_index = char_index + 2
    if (is_repeat or is_same_position) and M.last_search.last_target_index == char_index then
      -- 繰り返しの場合は、さらに先から検索
      start_index = char_index + 2
    end
    
    for i = start_index, line_length - 1 do
      local c = vim.fn.strcharpart(line, i, 1)
      if M.config.debug then
        print(string.format("t: Checking index %d: '%s'", i, c))
      end
      if is_target_char(c) then
        found_count = found_count + 1
        if found_count == count then
          target_index = i - 1
          break
        end
      end
    end
  elseif command == 'T' then
    -- 後方検索（文字の次まで）
    -- 同じコマンドの繰り返しで、前回と同じ位置にいる場合は、さらに前から検索
    local start_index = char_index - 1
    if (is_repeat or is_same_position) and M.last_search.last_target_index == char_index then
      -- 前回のターゲット文字を飛ばす
      start_index = char_index - 2
    end

    if start_index >= 0 then
      for i = start_index, 0, -1 do
        local c = vim.fn.strcharpart(line, i, 1)
        if M.config.debug then
          print(string.format("T: Checking index %d: '%s'", i, c))
        end
        if is_target_char(c) then
          found_count = found_count + 1
          if found_count == count then
            target_index = i + 1
            break
          end
        end
      end
    end
  end

  -- 見つかった場合はカーソルを移動
  if target_index and target_index >= 0 and target_index < line_length then
    if M.config.debug then
      print(string.format("Found at char index: %d", target_index))
      local found_char = vim.fn.strcharpart(line, target_index, 1)
      print(string.format("Moving to char: '%s'", found_char))
    end

    -- 0ベースの文字インデックスから0ベースのバイト位置に変換
    local target_byte_col = char_index_to_byte(line, target_index)

    if M.config.debug then
      print(string.format("Moving to byte col: %d", target_byte_col))
      print(string.format("Saving last search: command=%s, char=%s, last_target_index=%d",
        command, char, target_index))
    end

    set_cursor_pos(line_num, target_byte_col)

    -- 最後の検索情報を保存
    M.last_search = {
      command = command,
      char = char,
      chars = search_chars,
      last_target_index = target_index,
      last_position = {line_num, target_byte_col}
    }
    
    return true
  else
    if M.config.debug then
      print("Target not found")
    end
    -- ターゲットが見つからなかった場合も位置を更新
    M.last_search.last_position = {line_num, byte_col}
    return false
  end
end

-- コマンドをセットアップ
local function setup_command(cmd)
  -- ノーマルモードとビジュアルモードのマッピング
  vim.keymap.set({ 'n', 'v' }, cmd, function()
    -- セットアップされていない場合はエラー
    if not M.is_setup then
      error("ft-mapper: setup() must be called with mappings configuration")
    end

    -- カウントを取得
    local count = vim.v.count1

    -- 次の文字を取得
    local char = vim.fn.getcharstr()

    -- ESCが押された場合は何もしない
    if char == '\27' then
      return
    end

    -- マッピングを検索
    local mapping_table = build_mapping_table(M.config.mappings)
    local targets = mapping_table[char]

    -- マッピングが存在しない場合は、通常のコマンドを実行
    if not targets then
      -- 通常のf/tコマンドを実行して、その情報を保存
      vim.cmd('normal! ' .. count .. cmd .. char)
      local line_num, byte_col = get_cursor_pos()
      M.last_search = {
        command = cmd,
        char = char,
        chars = { char },
        last_position = {line_num, byte_col}
      }
      return
    end

    -- 検索対象の文字リストを作成
    local search_chars = { char }
    vim.list_extend(search_chars, targets)

    -- 検索を実行
    do_search(cmd, char, count, search_chars, false)
  end, { silent = true })
  
  -- オペレータペンディングモード専用のマッピング
  vim.keymap.set('o', cmd, function()
    -- セットアップされていない場合はエラー
    if not M.is_setup then
      error("ft-mapper: setup() must be called with mappings configuration")
    end

    -- カウントを取得
    local count = vim.v.count1

    -- 次の文字を取得
    local char = vim.fn.getcharstr()

    -- ESCが押された場合は何もしない
    if char == '\27' then
      return
    end

    -- マッピングを検索
    local mapping_table = build_mapping_table(M.config.mappings)
    local targets = mapping_table[char]

    -- マッピングが存在しない場合は、通常のコマンドを実行
    if not targets then
      -- 通常のf/tコマンドを実行
      vim.cmd('normal! ' .. count .. cmd .. char)
      local line_num, byte_col = get_cursor_pos()
      M.last_search = {
        command = cmd,
        char = char,
        chars = { char },
        last_position = {line_num, byte_col}
      }
      return
    end

    -- 検索対象の文字リストを作成
    local search_chars = { char }
    vim.list_extend(search_chars, targets)

    -- オペレータペンディングモードでの特別な処理
    local line = get_current_line()
    local start_line, start_col = get_cursor_pos()
    local start_char_index = byte_to_char_index(line, start_col)
    
    -- 一時的にビジュアルモードに入る
    vim.cmd('normal! v')
    
    -- 検索を実行
    local found = do_search(cmd, char, count, search_chars, false)
    
    if found then
      if cmd == 'f' or cmd == 'F' then
        -- f/F の場合、見つかった文字全体を含める（inclusive）
        local _, current_col = get_cursor_pos()
        local target_char_index = byte_to_char_index(line, current_col)
        local target_char = vim.fn.strcharpart(line, target_char_index, 1)
        local char_bytes = #target_char
        
        -- マルチバイト文字の場合、最後のバイトまで選択
        if char_bytes > 1 then
          set_cursor_pos(start_line, current_col + char_bytes - 1)
        end
        
        -- 方向を調整（Fの場合は逆順になる可能性がある）
        if cmd == 'F' and target_char_index < start_char_index then
          -- 選択範囲を正しく設定
          local temp_col = current_col
          set_cursor_pos(start_line, start_col)
          vim.cmd('normal! o')  -- 選択の他端に移動
          set_cursor_pos(start_line, temp_col)
        end
      end
      -- t/T の場合は特別な処理は不要（exclusive）
    else
      -- 見つからなかった場合はビジュアルモードを解除
      vim.cmd('normal! \27') -- ESC
    end
  end, { silent = true, expr = false })
end

-- 繰り返し検索用のコマンドをセットアップ
local function setup_repeat_commands()
  -- ; で同じ方向に繰り返し
  vim.keymap.set({ 'n', 'v', 'o' }, ';', function()
    if not M.last_search.command then
      -- デフォルトの動作にフォールバック
      vim.cmd('normal! ;')
      return
    end

    local count = vim.v.count1
    
    -- オペレータペンディングモードの場合は特別な処理
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'no' then
      vim.cmd('normal! v')
      do_search(M.last_search.command, M.last_search.char, count, M.last_search.chars, true)
      
      -- f/F の場合、文字全体を選択
      if M.last_search.command == 'f' or M.last_search.command == 'F' then
        local line = get_current_line()
        local _, current_col = get_cursor_pos()
        local target_char_index = byte_to_char_index(line, current_col)
        local target_char = vim.fn.strcharpart(line, target_char_index, 1)
        local char_bytes = #target_char
        
        if char_bytes > 1 then
          local line_num = vim.api.nvim_win_get_cursor(0)[1]
          set_cursor_pos(line_num, current_col + char_bytes - 1)
        end
      end
    else
      do_search(M.last_search.command, M.last_search.char, count, M.last_search.chars, true)
    end
  end, { silent = true })

  -- , で逆方向に繰り返し
  vim.keymap.set({ 'n', 'v', 'o' }, ',', function()
    if not M.last_search.command then
      -- デフォルトの動作にフォールバック
      vim.cmd('normal! ,')
      return
    end

    local count = vim.v.count1
    -- 逆方向のコマンドに変換
    local reverse_cmd = {
      f = 'F',
      F = 'f',
      t = 'T',
      T = 't'
    }
    
    -- オペレータペンディングモードの場合は特別な処理
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'no' then
      vim.cmd('normal! v')
      do_search(reverse_cmd[M.last_search.command], M.last_search.char, count, M.last_search.chars, true)
      
      -- f/F の場合、文字全体を選択
      local original_cmd = M.last_search.command
      if original_cmd == 'f' or original_cmd == 'F' then
        local line = get_current_line()
        local _, current_col = get_cursor_pos()
        local target_char_index = byte_to_char_index(line, current_col)
        local target_char = vim.fn.strcharpart(line, target_char_index, 1)
        local char_bytes = #target_char
        
        if char_bytes > 1 then
          local line_num = vim.api.nvim_win_get_cursor(0)[1]
          set_cursor_pos(line_num, current_col + char_bytes - 1)
        end
      end
    else
      do_search(reverse_cmd[M.last_search.command], M.last_search.char, count, M.last_search.chars, true)
    end
  end, { silent = true })
end

-- セットアップ関数
function M.setup(opts)
  -- 既にセットアップ済みの場合は設定のみ更新
  if M.is_setup and opts then
    M.config = vim.tbl_deep_extend('force', M.config, opts)
    return
  end

  -- オプションが指定されていない場合はエラー
  if not opts or not opts.mappings then
    error("ft-mapper: mappings configuration is required")
  end

  -- ユーザー設定を適用
  M.config = vim.tbl_deep_extend('force', {
    mappings = {},
    debug = false
  }, opts)

  -- マッピングが空の場合はエラー
  if #M.config.mappings == 0 then
    error("ft-mapper: at least one mapping is required")
  end

  -- デバッグ用: 設定内容を出力
  if M.config.debug then
    print("ft-mapper config:")
    print(vim.inspect(M.config))
  end

  -- 各コマンドをセットアップ
  setup_command('f')
  setup_command('F')
  setup_command('t')
  setup_command('T')

  -- 繰り返しコマンドをセットアップ
  setup_repeat_commands()

  -- セットアップ完了フラグ
  M.is_setup = true
end

-- 設定を確認するためのコマンド
function M.show_config()
  print("ft-mapper current config:")
  print(vim.inspect(M.config))
end

return M
