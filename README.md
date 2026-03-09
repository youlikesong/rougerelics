# Rogue Relics

Godot 4.x 2D 俯视角动作 Roguelite 原型项目。  
灵感来源：The Binding of Isaac + Brotato + Warcraft RPG 地图推进。

## 当前状态（Vertical Slice）

已实现可游玩的 1-1 关卡竖切版本：

- 玩家移动（WASD）
- 8 方向射击（方向键）
- 玩家 HP 与死亡流程
- 普通近战追击敌人
- 1-1 Boss 战
- Boss 死亡后掉落装备
- 拾取后立即装备（当前为单装备槽模型）
- 关卡通关后返回 Hub
- Hub 中可查看装备状态与关卡解锁状态

## 引擎与技术栈

- Engine: Godot 4.x
- Language: GDScript（含类型标注）
- 架构原则：小脚本、模块化、数据驱动（装备/关卡/掉落）

## 目录结构

```text
scenes/
  player/
  enemies/
  weapons/
  equipment/
  levels/
  ui/
systems/
data/
```

## 关键场景与脚本

- Hub 场景：`scenes/levels/Hub.tscn`
- 1-1 关卡：`scenes/levels/Stage1_1.tscn`
- 关卡逻辑：`scenes/levels/Stage1_1.gd`
- 全局状态（autoload）：`systems/game_state.gd`
- 玩家：`scenes/player/Player.tscn` + `scenes/player/Player.gd`

## 运行方式

### 运行完整项目

1. 用 Godot 4 打开项目根目录（包含 `project.godot`）。
2. 按 `F5` 运行主场景（当前默认是 Hub）。

### 仅运行 1-1 关卡

1. 在编辑器中打开 `scenes/levels/Stage1_1.tscn`。
2. 按 `F6`（Run Current Scene）。

## 操作说明

- 移动：`W A S D`
- 射击：`方向键`（支持 8 方向）

## 数据驱动文件

- 装备定义：`data/equipment/equipment.json`
- 关卡定义：`data/stages/stages.json`

## 存档与进度

- 通过 `GameState` 管理解锁/通关/已装备信息。
- 本地保存路径：`user://progress.cfg`

## 已知限制（当前里程碑）

- 目前仅完整实现 Stage 1-1（1-2 仅有解锁记录示例）
- 装备系统当前为单件生效模型
- 关卡编排逻辑主要在 `Stage1_1.gd`，后续可抽离为可复用关卡流程管理

## 下一步建议

- 扩展 1-2 到 1-6 关卡内容
- 将关卡流程、奖励流程进一步模块化
- 增加更多敌人/武器/装备条目
- 加入音效、动画、掉落反馈与数值平衡
