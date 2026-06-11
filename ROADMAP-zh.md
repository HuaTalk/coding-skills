# 路线图

开源版 Claude Code plugin 框架的后续改进项，按 ROI 排列。

## #1 — CI 校验 + pre-commit

**问题**：plugin 给别人用，路径错误、frontmatter 缺失、JSON 格式非法等问题当前无自动化检查。

**落地动作**：
- `scripts/check.sh`：校验 `skills/*/SKILL.md` frontmatter（`name` / `description` 必填）、`.claude-plugin/*.json` JSON 合法性、凭证泄露扫描
- GitHub Actions（或等效 CI）：PR 触发自动跑 `check.sh`
- pre-commit hook：本地提交前跑，拦截低级错误

## #2 — 英文 README + 国际化

**问题**：当前仅中文 README，开源受众窄。

**落地动作**：
- `README.md` → `README.zh.md`（已完成）
- 新 `README.md` 英文版为默认入口（已完成）
- 目录树、配置指南、skill 选用指南全量英文化（已完成）

## #3 — skill 创建模板

**问题**：新增 skill 无起点模板，容易遗漏 `metadata.status`、`hooks:`、触发关键词等字段。

**落地动作**：
- `templates/skill-template.md`：含 frontmatter 必需字段 + 推荐文件结构（`references/`、`templates/` 子目录约定）
- `skill-simplifier` 新增"对照模板检查"步骤

## #4 — domain-context 模板可配置

**问题**：`domain-context` 的 11 节固定模板适合流水线型业务，但不适合所有团队。

**落地动作**：
- skill 加载模板时优先读 `{项目根}/knowledge/.domain-module-template.md`
- fallback 到 `skills/domain-context/templates/domain-module-template.md`
- 模板节标题可覆盖，但不能删除核心语义（输入/输出/不输出）

## #5 — cross-skill 一致性审查

**问题**：10 个 skill 各自演化，交叉引用可能断链（`[[domain-context]]` 改名后旧引用残留在 `best-effort-delivery` 里），反模式/写作风格不统一。

**落地动作**：
- `scripts/check-cross-refs.sh`：grep 所有 `[[skill-name]]` 引用，验证目标 skill 存在
- 统一写作规范：frontmatter 字段顺序、中文/英文段落分隔、代码块语言标注

## #6 — 测试：skill 触发匹配验证

**问题**：skill 的 `description` 字段是 dispatcher 的唯一匹配面。缩减关键词后可能丢召回，但当前无法自动化验证。

**落地动作**：
- `scripts/test-skill-triggers.sh`：对每个 skill 列出预设触发句，模拟匹配（grep/模糊），报告未命中
- 不追求 100% 覆盖率，重点覆盖高频触发词

## #7 — 版本发布与 changelog

**问题**：plugin 消费者通过 `/plugin update` 升级，但没有 changelog 告知改了什么、是否 breaking。

**落地动作**：
- `CHANGELOG.md`：语义化版本，每个 release 列出 Added / Changed / Removed / Fixed
- `plugin.json` 版本号与 git tag 同步

## #8 — 社区贡献指南

**问题**：开源后外部贡献者不知道如何提 PR、skill 写作规范是什么。

**落地动作**：
- `CONTRIBUTING.md`：PR 流程、skill 设计哲学（"Rules Are for You"）、review 标准
- Issue 模板（bug report / skill proposal / feature request）
