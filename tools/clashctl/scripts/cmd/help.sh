#!/usr/bin/env bash

clashhelp() {
  cat <<EOF

Usage:
  clashctl COMMAND [OPTIONS]

Commands:
  on                    开启代理
  off                   关闭代理
  status                内核状态
  ui                    面板地址
  add <url>             添加并立即使用订阅
  del <id>              删除订阅（可删除当前订阅）
  ls                    查看订阅
  use <id>              切换订阅
  update [id]           更新订阅
  sub                   订阅管理
  tun                   Tun 模式
  mixin                 Mixin 配置
  secret                Web 密钥
  log                   查看日志
  upgrade               升级内核

Global Options:
  -h, --help            显示帮助信息

For more help on how to use clashctl, head to https://github.com/nelvko/clash-for-linux-install
EOF
}
