# Roadmap

开源版 Claude Code plugin 框架的后续改进项，按 ROI 排列。

## #1 — domain-context 模板可配置

**问题**：`domain-context` 的固定模板适合流水线型业务，但不适合所有团队。当前硬编码路径 `skills/domain-context/templates/domain-module-template.md`，消费者无法自定义。

**落地动作**：
- skill 加载模板时优先读 `{项目根}/knowledge/.domain-module-template.md`
- fallback 到 `skills/domain-context/templates/domain-module-template.md`
- 模板节标题可覆盖，但不能删除核心语义（输入/输出/不输出）

## #3 — skill 触发匹配验证

**现状**：`scripts/test-skill-triggers.sh` 为每个 skill 固定高频触发词，并由 `scripts/check.sh` 在 CI 和 pre-commit 中强制校验。它验证 dispatcher 输入面是否发生意外删词，不模拟模型召回率。

**后续动作**：
- 随真实使用反馈补充高频触发词
- 需要更真实的召回评估时，再引入独立的 dispatcher 测试环境

## 已完成

- ~~CI 校验 + pre-commit~~：`scripts/check.sh` 统一校验 manifest、skill frontmatter、库存文档、版本/changelog、凭证模式和安装器；GitHub Actions 与 pre-commit 复用同一脚本
- ~~发布流程自动化~~：release 文档约定 `v<version>` tag，tag workflow 校验 tag 与 `plugin.json` 版本一致
- ~~skill 触发匹配验证~~：`scripts/test-skill-triggers.sh` 固定 11 个高频触发词，由统一检查脚本强制运行
- ~~社区贡献指南~~：`CONTRIBUTING.md` 说明 skill 写作、验证、安全边界、review 和 release 约定
- ~~i18n 双版本~~：最初支持中英双版本（SKILL-zh.md、CLAUDE-zh.md 等），现改为每个 skill 只维护一个 canonical 文件；canonical 内容可按团队用户使用中文、英文或混用
- ~~cross-skill 一致性审查~~：通过原子化重构消除所有 19 个跨 skill 引用（`f8da7d7`），不再需要独立脚本
- ~~skill 创建模板~~：新 skill 创建频率接近零，不单独维护模板文件；写作规范并入 CONTRIBUTING.md 即可
- ~~install.sh 健壮性~~：安装路径统一为 plugin marketplace。install.sh 保留但不再作为推荐路径，以后需要选 skill 时再加强
