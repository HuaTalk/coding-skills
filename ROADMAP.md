# Roadmap

开源版 Claude Code plugin 框架的后续改进项，按 ROI 排列。

## #1 — CI 校验 + pre-commit

**问题**：plugin 给别人用，路径错误、frontmatter 缺失（`name` / `description` 必填）、JSON 格式非法、SKILL-zh.md 缺漏等问题当前无自动化检查。

**落地动作**：
- `scripts/check.sh`：
  - 校验 `skills/*/SKILL.md` frontmatter（`name` / `description` 必填，`metadata.status` 在允许值范围内）
  - 校验 `skills/*/SKILL-zh.md` 与 SKILL.md 一一对应（i18n 完整性）
  - 校验 `.claude-plugin/*.json` JSON 合法性
  - 凭证泄露扫描（`ghp_`、`sk-` 等模式）
- GitHub Actions（或等效 CI）：PR 触发自动跑 `check.sh`
- pre-commit hook：本地提交前跑，拦截低级错误

## #2 — 版本发布与 Changelog

**问题**：plugin 消费者通过 `/plugin update` 升级，但没有 changelog 告知改了什么、是否 breaking。`plugin.json` 版本号停留在 0.1.0，未跟随实际变更迭代。

**落地动作**：
- `CHANGELOG.md`：语义化版本，每个 release 列出 Added / Changed / Removed / Fixed
- `plugin.json` 版本号与 git tag 同步
- release 流程文档（打 tag → 写 changelog → 通知消费者）

## #3 — 社区贡献指南

**问题**：开源后外部贡献者不知道如何提 PR、skill 写作规范是什么。

**落地动作**：
- `CONTRIBUTING.md`：PR 流程、skill 设计哲学（"Rules Are for You"）、review 标准
- Issue 模板（bug report / skill proposal / feature request）

## #4 — domain-context 模板可配置

**问题**：`domain-context` 的固定模板适合流水线型业务，但不适合所有团队。当前硬编码路径 `skills/domain-context/templates/domain-module-template.md`，消费者无法自定义。

**落地动作**：
- skill 加载模板时优先读 `{项目根}/knowledge/.domain-module-template.md`
- fallback 到 `skills/domain-context/templates/domain-module-template.md`
- 模板节标题可覆盖，但不能删除核心语义（输入/输出/不输出）

## #5 — skill 触发匹配验证

**问题**：skill 的 `description` 字段是 dispatcher 的唯一匹配面。缩减关键词后可能丢召回，但当前无法自动化验证。

**落地动作**：
- `scripts/test-skill-triggers.sh`：对每个 skill 列出预设触发句，模拟匹配（grep/模糊），报告未命中
- 不追求 100% 覆盖率，重点覆盖高频触发词
- 作为 #1 CI 流程的可选步骤（允许部分未命中，不阻塞 PR）

## #6 — /hide Skill: Proactive Hiding（事前隐藏）

**问题**：`/hide` v1.0 只支持事后文件清理，用户必须在规则泄露发生后手动执行。更理想的方案是在会话开始前建立隐藏纪律，AI 在 Hidden CoT 中处理规则，visible output 绝不泄露。

**落地动作**：
- **Proactive Mode**: `/hide` 作为 session 级模式（非一次性命令），激活后 AI 在整个 session 中静默遵守隐藏规则
- **Hidden CoT 协议**: 利用 Claude Code AI 的 internal reasoning（已对用户隐藏）和 visible output 两层边界，规则处理只在 Hidden CoT 中，结果只进入 visible output
- **用户自定义隐藏目标**: `/hide <自然语言描述>` 支持用户指定隐藏目标，如 "隐藏mock数据"、"不要提及内部代号"
- **退出机制**: 不需要 `/hide:off`，通过 `/handoff` 或新 session 退出

**范围**：
- 调研 Hidden CoT 机制在 Claude Code 中的可行性和边界
- 设计 Proactive Mode 的 activation protocol
- 自定义目标与内置规则的合并策略

**详见**: `docs/hide-skill-design/`

## 已完成

- ~~英文 README + 国际化~~：README.md 英文化、全部 9 个 skill 中英双版本、CLAUDE.md/commands 双版本、install.sh --lang、i18n-switch.sh —— 全部完成于 2026-06-11
- ~~cross-skill 一致性审查~~：通过原子化重构消除所有 19 个跨 skill 引用（`f8da7d7`），不再需要独立脚本
- ~~skill 创建模板~~：新 skill 创建频率接近零，不单独维护模板文件；写作规范并入 CONTRIBUTING.md 即可
- ~~install.sh 健壮性~~：安装路径统一为 plugin marketplace + 英文。install.sh 保留但不再作为推荐路径，以后需要选语言/选 skill 时再加强
