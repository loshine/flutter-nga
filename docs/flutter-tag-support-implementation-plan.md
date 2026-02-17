# flutter-nga 论坛标签补齐实现计划

更新时间：2026-02-17  
基线文档：`docs/forum-tag-support-comparison.md`

## 目标

- 目标：把 flutter-nga 的论坛标签支持度提升到接近 MNGA（优先补齐缺失标签与严重语义偏差）。
- 非目标：本计划不改发帖业务接口，仅改“内容解析与渲染”链路。

## 需补齐项（只列“支持不足/未支持”）

| 优先级 | 标签/能力 | 当前状态 | 目标状态 |
|---|---|---|---|
| P0 | `[noimg]` | 无 | 按发帖日期还原附件 URL 并展示图片/视频 |
| P0 | `[attach]` | 无 | 渲染为可点击附件入口 |
| P0 | `[code]` | 无 | 等宽字体块渲染，保留换行 |
| P0 | 通用 `[uid]/[pid]/[tid]` | 仅回帖头模板可用 | 任意位置可解析为站内链接 |
| P0 | `[@ user]` | 无 | 解析为用户链接 |
| P0 | `[flash=audio]` | 无 | 渲染音频入口（至少外链跳转） |
| P0 | `[collapse]` | 仅输出 `<collapse>` | 真正可折叠/展开 |
| P0 | `[s:xxx]` 表情 | 仅输出 `<nga_emoticon>` | 表情图片正确渲染 |
| P0 | `======` 分割线 | 仅输出 `<nga_hr>` | 显示稳定分割线 |
| P0 | 未知标签兜底 | 无 | 按 `[tag]...[/tag]` 回退显示 |
| P1 | `[td rowspan/colspan]` | 语法转换不完整 | 输出合法标签并正确渲染跨行跨列 |
| P1 | `[album]` | 无专用渲染 | 标题 + 图片组渲染 |
| P1 | `[flash]` | 仅“站外视频”文本链接 | 区分视频/音频语义 |
| P1 | `[color]` | 仅 `[a-z]+` | 支持更多合法色值（含 hex） |
| P1 | `[size]` | 仅 `%` 且属性不标准 | 输出标准样式并稳定生效 |
| P1 | `[font]` | 实际效果不稳定 | 统一字体回退策略 |
| P1 | `[list] + [*]` | 复杂嵌套不稳 | 嵌套列表稳定 |
| P1 | `[stripbr]` | 无 | 兼容为换行 |

## 分阶段落地

### Phase 1（P0）：先补“缺失标签 + 渲染空洞”

1. 渲染器扩展接入（先不大改 parser）  
目标文件：`lib/ui/widget/nga_html_content_widget.dart`
- 为 `collapse`、`nga_emoticon`、`nga_hr` 增加自定义扩展渲染。
- 将现有 `CollapseWidget` 接入真实渲染链路（当前仅定义未使用）。

2. 增补缺失标签解析  
目标文件：`lib/utils/parser/content_parser.dart`
- 新增 `[noimg]`、`[attach]`、`[code]`、`[@ user]`、`[flash=audio]`、`[stripbr]` 的解析规则。
- 将通用 `uid/pid/tid` 从“模板匹配”升级为“标签匹配”。

3. 未知标签兜底  
目标文件：`lib/utils/parser/content_parser.dart`
- 对未识别标签提供可选回退输出（保留原标签文本，避免信息丢失）。

### Phase 2（P1）：修语义偏差与结构标签

1. 表格标签修复  
目标文件：`lib/utils/parser/content_parser.dart`
- 修复 `[td rowspan/colspan]` 生成 HTML 缺 `>` 的问题。
- 校验 `tdN`、`rowspan`、`colspan` 组合输出合法性。

2. 样式标签规范化  
目标文件：`lib/utils/parser/content_parser.dart`
- `[size]` 输出改为标准 `style="font-size:..."`。
- `[color]` 支持 hex；`[font]` 增加安全字体白名单/回退。

3. `album` 与 `list` 语义增强  
目标文件：`lib/utils/parser/content_parser.dart`、`lib/ui/widget/nga_html_content_widget.dart`
- `album` 输出结构化节点并提供组件渲染。
- 列表项从脆弱正则改为结构化解析（避免嵌套错位）。

### Phase 3（稳定性）：减少正则方案的结构性风险

1. 解析器重构（建议）  
新增文件建议：`lib/utils/parser/ubb_parser.dart`、`lib/utils/parser/ubb_node.dart`
- 从“全量正则替换”升级为“tokenize + 栈式 AST”。
- 支持嵌套标签、坏闭合标签、未知标签保留。

2. 转换层统一  
新增文件建议：`lib/utils/parser/ubb_renderer.dart`
- AST -> 渲染节点（或 HTML）统一出口，减少规则分散。

## 测试与验收

### Parser 测试

- 新增：`test/parser/tag_compatibility_test.dart`
- 覆盖：`noimg/attach/code/uid/pid/tid/@/flash=audio/collapse/td rowspan-colspan/stripbr/unknown-tag`。

### Widget 测试

- 新增：`test/widget/tag_render_test.dart`
- 覆盖：`collapse` 可展开、`nga_emoticon` 可见、`nga_hr` 可见、`album` 渲染正确。

## 验收标准

- P0 标签：在帖子正文中可正确解析并渲染，不再出现裸 UBB。
- P1 标签：复杂表格和样式标签在典型帖子样本中稳定展示。
- 兼容性：未知标签不丢内容，至少可读回退。

## 实施顺序建议（按 PR 拆分）

1. PR-1：渲染扩展接入 + `collapse/nga_emoticon/nga_hr`。  
2. PR-2：P0 缺失标签解析（`noimg/attach/code/@/uid-pid-tid/flash=audio/stripbr`）+ 未知标签兜底。  
3. PR-3：表格与样式修复（`td span/color/size/font/list`）。  
4. PR-4：解析器结构化重构（AST）与回归测试补齐。
