# MNGA 与 flutter-nga 论坛标签支持对比

更新时间：2026-02-17

## 范围与依据

- 比较范围：帖子/评论内容的“标签解析 + 渲染”链路。
- MNGA 依据：`logic/text/src/content.rs:14`、`app/Shared/Utilities/ContentCombiner.swift:68`、`app/Shared/Utilities/ContentCombiner.swift:473`。
- flutter-nga 依据：`lib/utils/parser/content_parser.dart:86`、`lib/ui/widget/nga_html_content_widget.dart:27`、`lib/ui/widget/collapse_widget.dart:3`。

## 两端“可识别标签”全集

### MNGA

- 显式渲染分支标签：`h`、`img`、`album`、`noimg`、`quote`、`b`、`uid`、`pid`、`tid`、`url`、`code`、`u`、`i`、`del`、`color`、`size`、`collapse`、`flash`、`attach`、`list`、`align`、`table`、`tr`、`td*`、`dice`、`at`。
- 语法/衍生标签：`_divider`（来自 `===...===` 或 `======`）、`[s:xxx]` 表情、`[@ user]`、`[*]`、`[stripbr]`。
- 兼容策略：未知标签进入默认分支并按 `[tag]...[/tag]` 回退显示。

### flutter-nga

- `_AlbumParser`：`[album]`、`[album=title]`。
- `_TableParser`：`[table]`、`[tr]`、`[td]`、`[tdN]`、`[td rowspan=..]`、`[td rowspan=.. colspan=..]`。
- `_ContentParser`：`[img]`、`[url]`、`[url=]`、`[flash]`、`[collapse]`、`[collapse=]`、`[color=...]`、`[align=...]`、`[l]/[r]`、`[h]`、`===...===`、`[size=..%]`、`[font=...]`、`[b]/[i]/[u]/[del]`、`[list]`、`[*]`、`[quote]`、`======`、`------`。
- `_DiceParser`：`[dice]...[/dice]`。
- `_ReplyParser`：仅固定回帖头模板中的 `uid/pid/tid`。
- `_EmoticonParser`：将预置表情文本（如 `[s:ac:哭笑]`）替换为 `<nga_emoticon ...>`。

## 对比表（标签维度）

说明：`完全` = 语义与展示基本到位；`部分` = 可解析但语义/展示不完整；`无` = 当前未实现。

| 标签/语法 | MNGA | flutter-nga | 结论 |
|---|---|---|---|
| `[img]...[/img]` | 完全 | 完全 | 两端都可用 |
| `[noimg]...[/noimg]` | 完全 | 无 | flutter 缺失 |
| `[album]` / `[album=标题]` | 完全 | 部分 | flutter 仅转 `<album>`，无专用渲染 |
| `[quote]...[/quote]` | 完全 | 完全 | 两端都可用 |
| `[b]...[/b]` | 完全 | 完全 | 两端都可用 |
| `[i]...[/i]` | 完全 | 完全 | 两端都可用 |
| `[u]...[/u]` | 完全 | 完全 | 两端都可用 |
| `[del]...[/del]` | 完全 | 完全 | 两端都可用 |
| `[code]...[/code]` | 完全 | 无 | flutter 缺失 |
| `[url]...[/url]` / `[url=...]...[/url]` | 完全 | 完全 | 两端都可用 |
| `[uid]` / `[uid=...]`（通用） | 完全 | 部分 | flutter 仅在回帖头模板中处理 |
| `[pid=...]`（通用） | 完全 | 部分 | flutter 仅在回帖头模板中处理 |
| `[tid=...]`（通用） | 完全 | 部分 | flutter 仅在回帖头模板中处理 |
| `[@ user]` | 完全 | 无 | flutter 缺失 |
| `[dice]...[/dice]` | 完全 | 完全 | 两端都可用 |
| `[flash]...[/flash]` | 完全 | 部分 | flutter 仅转“站外视频”链接文本 |
| `[flash=audio]...[/flash]` | 完全 | 无 | flutter 缺失 |
| `[attach]...[/attach]` | 完全 | 无 | flutter 缺失 |
| `[collapse]` / `[collapse=标题]` | 完全 | 部分 | flutter 仅生成 `<collapse>`，未接入折叠组件 |
| `[list]...[/list]` + `[*]` | 完全 | 部分 | flutter 基本可用，但 `[*]` 为正则替换，复杂嵌套不稳 |
| `[align=center|left|right]` | 完全 | 部分 | flutter 仅正则输出 `<div align=...>`，语义依赖 HTML 解释器 |
| `[l]...[/l]` / `[r]...[/r]` | 无 | 完全 | 该项 flutter 覆盖更多 |
| `[table]...[/table]` | 完全 | 完全 | 基本都可用 |
| `[tr]...[/tr]` | 完全 | 完全 | 基本都可用 |
| `[td]...[/td]` | 完全 | 完全 | 基本都可用 |
| `[tdN]`（如 `[td20]`） | 部分 | 完全 | MNGA 不处理宽度语义；flutter 转为 width% |
| `[td rowspan/colspan]` | 部分 | 部分 | MNGA 仅处理 `colspan`；flutter 生成标签缺 `>` |
| `[color=...]...[/color]` | 部分 | 部分 | MNGA 限白名单色；flutter 仅支持 `[a-z]+` |
| `[size=...]...[/size]` | 部分 | 部分 | MNGA 在低系统版本可能无缩放；flutter 仅 `%` 且用非标准属性 |
| `[font=...]...[/font]` | 部分 | 部分 | MNGA 忽略 `font` 标签样式；flutter 依赖 HTML 样式支持 |
| `[h]...[/h]` / `===标题===` | 完全 | 完全 | 两端都可用 |
| `======` 分割线 | 完全 | 部分 | flutter 转 `<nga_hr>` 但无自定义渲染 |
| `------` 分割线 | 无 | 部分 | flutter 转空 `h5`，语义不稳定 |
| `[s:xxx]` 表情 | 完全 | 部分 | flutter 转 `<nga_emoticon>` 但未接入专用渲染 |
| `[stripbr]` | 完全 | 无 | flutter 缺失 |
| 未知标签回退 | 完全 | 无 | MNGA 有兜底；flutter 无统一兜底 |

## 关键差异结论

- MNGA 的策略是“通用解析 + 专项渲染 + 未知标签兜底”，容错更强。
- flutter-nga 当前策略是“正则替换为 HTML”，对复杂嵌套、未知标签和自定义标签（`collapse`/`nga_emoticon`/`nga_hr`）支持不足。
- flutter-nga 需要优先补齐：`noimg`、`attach`、`code`、通用 `uid/pid/tid`、`[@ user]`、`flash=audio`、`stripbr`、未知标签兜底。
