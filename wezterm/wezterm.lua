-- NOTE: 関数を保護されたモードで呼び出すpcallを使って、weztermを呼び出す。
-- pcallの最初の戻り値がfalseの時は、funcの実行中にエラーが発生している。
--
-- http://www.rtpro.yamaha.co.jp/RT/docs/lua/tutorial/library.html#pcall
local status, wezterm = pcall(require, 'wezterm')
if (not status) then return end

-- os.dateによって返却された数値から曜日を判定し、漢字に変換する
-- (曜日, 1–7, 日曜日が 1)
local function day_of_week_ja(w_num)
    if w_num == 1 then
        return 'Sun'
    elseif w_num == 2 then
        return 'Mon'
    elseif w_num == 3 then
        return 'Tue'
    elseif w_num == 4 then
        return 'Wed'
    elseif w_num == 5 then
        return 'Thu'
    elseif w_num == 6 then
        return 'Fri'
    elseif w_num == 7 then
        return 'Sat'
    end
end

-- 年月日と時間、バッテリーの残量をステータスバーに表示する
-- ウィンドウが最初に表示されてから1秒後に開始され、1秒に1回トリガーされるイベント
wezterm.on('update-status', function(window, pane)
    -- 日付のtableを作成する方法じゃないと曜日の取得がうまくいかなかった
    -- NOTE: https://www.lua.org/pil/22.1.html
    local wday = os.date('*t').wday
    -- 指定子の後に半角スペースをつけないと正常に表示されなかった
    local wday_ja = string.format('(%s)', day_of_week_ja(wday))
    local date = wezterm.strftime('%Y-%m-%d' .. wday_ja .. ' %H:%M:%S');

    local bat = ''

    for _, b in ipairs(wezterm.battery_info()) do
        local battery_state_of_charge = b.state_of_charge * 100;
        local battery_icon = ''

        bat = string.format('%s%.0f%% ', battery_icon, battery_state_of_charge)
    end

    window:set_right_status(wezterm.format {
        { Text = date .. '  ' .. bat },
    })
end)

-- タブの表示をカスタマイズ
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local tab_index = tab.tab_index + 1

    -- Copymode時のみ、"Copymode..."というテキストを表示
    if tab.is_active and string.match(tab.active_pane.title, 'Copy mode:') ~= nil then
        return string.format(' %d %s ', tab_index, 'Copy mode...')
    end

    local pane = tab.active_pane
    local title = pane.title

    return string.format('%s ', ' ' .. pane.tab_title .. ' ')
end)

local base_colors = {
    dark = '#172331',
    yellow = '#ffe64d'
}

local colors = {
    cursor_bg = base_colors['yellow'],
    split = '#6fc3df',
    -- the foreground color of selected text
    selection_fg = base_colors['dark'],
    -- the background color of selected text
    selection_bg = base_colors['yellow'],
    tab_bar = {
        background = base_colors['dark'],
        -- The active tab is the one that has focus in the window
        active_tab = {
            bg_color = 'aliceblue',
            fg_color = base_colors['dark'],
        },
        -- plus button hidden
        new_tab = {
            bg_color = base_colors['dark'],
            fg_color = base_colors['dark'],
        },
    },
}

-- キーバインドの設定、macOSの場合は以下のようになる
--
-- CTRL →  CMD
-- ALT → OPTION

-- leader keyを CTRL + kにマッピング
local leader = { key = 'k', mods = 'CTRL', timeout_milliseconds = 1000 };
local act = wezterm.action;
local keys = {
    -- CMD + cでタブを新規作成
    { key = 'c',     mods = 'LEADER', action = act({ SpawnTab = 'CurrentPaneDomain' }) },
    -- CMD + xでタブを閉じる
    { key = 'x',     mods = 'LEADER', action = act({ CloseCurrentTab = { confirm = true } }) },
    -- CTRL + q + numberでタブの切り替え
    { key = '1',     mods = 'LEADER', action = act({ ActivateTab = 0 }) },
    { key = '2',     mods = 'LEADER', action = act({ ActivateTab = 1 }) },
    { key = '3',     mods = 'LEADER', action = act({ ActivateTab = 2 }) },
    { key = '4',     mods = 'LEADER', action = act({ ActivateTab = 3 }) },
    { key = '5',     mods = 'LEADER', action = act({ ActivateTab = 4 }) },
    { key = '6',     mods = 'LEADER', action = act({ ActivateTab = 5 }) },
    { key = '7',     mods = 'LEADER', action = act({ ActivateTab = 6 }) },
    { key = '8',     mods = 'LEADER', action = act({ ActivateTab = 7 }) },
    { key = '9',     mods = 'LEADER', action = act({ ActivateTab = 8 }) },
    -- PANEを水平方向に開く
    { key = ']',     mods = 'LEADER', action = act({ SplitVertical = { domain = 'CurrentPaneDomain' } }) }, -- PANEを縦方向に開く
    { key = '[',     mods = 'LEADER', action = act({ SplitHorizontal = { domain = 'CurrentPaneDomain' } }) },
    -- hjklでPANEを移動する
    { key = 'h',     mods = 'LEADER', action = act({ ActivatePaneDirection = 'Left' }) },
    { key = 'l',     mods = 'LEADER', action = act({ ActivatePaneDirection = 'Right' }) },
    { key = 'k',     mods = 'LEADER', action = act({ ActivatePaneDirection = 'Up' }) },
    { key = 'j',     mods = 'LEADER', action = act({ ActivatePaneDirection = 'Down' }) },
    -- PANEを閉じる
    { key = 'x',     mods = 'ALT',    action = act({ CloseCurrentPane = { confirm = true } }) },
    -- ALT + hjklでペインの幅を調整する
    { key = 'h',     mods = 'ALT',    action = act({ AdjustPaneSize = { 'Left', 5 } }) },
    { key = 'l',     mods = 'ALT',    action = act({ AdjustPaneSize = { 'Right', 5 } }) },
    { key = 'k',     mods = 'ALT',    action = act({ AdjustPaneSize = { 'Up', 5 } }) },
    { key = 'j',     mods = 'ALT',    action = act({ AdjustPaneSize = { 'Down', 5 } }) },
    -- QuickSelect・・・画面に表示されている文字をクイックにコピペできる機能
    { key = 'Enter', mods = 'SHIFT',  action = 'QuickSelect' },
}

-- デフォルトディレクトリを/Documents/に変更
-- NOTE: ~でホームディレクトリを指定する方法だとうまくいかなかった
-- local default_cwd = os.getenv('HOME')..'/Documents/'

return {
    color_scheme = 'nightfox',
    -- color_scheme = 'Neon',
    --default_cwd = default_cwd,
    colors = colors,
    leader = leader,
    keys = keys,
    font = wezterm.font("CommitMono", { weight = "Regular", stretch = "Normal", italic = false, logatures = true }),
    font_size = 14.0,
    line_height = 1.25,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    -- アクティブではないペインの彩度を変更しない
    inactive_pane_hsb = {
        saturation = 1,
        brightness = 1,
    },
    window_background_opacity = 0.7
}
