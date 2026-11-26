# 回收站：交互式 rm 包装（同盘 rename，跨盘才复制）
# 目录列表由 ~/.zprofile 的 TRASH_DIRS 提供；未定义时只用 $HOME/.mytrash

if (( ${#TRASH_DIRS[@]} == 0 )); then
    TRASH_DIRS=("${HOME}/.mytrash")
fi

# 设备号：Linux 用 stat -c，macOS 用 stat -f
_trash_dev(){
    stat -c %d "$1" 2>/dev/null || stat -f %d "$1" 2>/dev/null
}

# 选同盘的回收站；没有匹配就回退列表里的第一个
_trash_pick(){
    local target="$1"
    local dev=$(_trash_dev "$(dirname "$target")")
    local d
    for d in "${TRASH_DIRS[@]}"; do
        [ -d "$(dirname "$d")" ] || continue
        [ "$(_trash_dev "$(dirname "$d")")" = "$dev" ] && echo "$d" && return 0
    done
    echo "${TRASH_DIRS[1]}"
    return 1
}

_trash_dirs(){
    local d
    for d in "${TRASH_DIRS[@]}"; do [ -d "$d" ] && echo "$d"; done
}

# mv命令覆盖rm命令（同盘 rename；时间戳避免重名）
func_delfile(){
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local interactive=0
    local targets=()
    local item

    # 解析参数：-rf 之类的选项一律忽略；-i 保留交互询问；-- 结束选项
    for item in "$@"; do
        case "$item" in
            --) ;;
            -i|--interactive) interactive=1 ;;
            -*) ;;
            *) targets+=("$item") ;;
        esac
    done

    for item in "${targets[@]}"; do
        case "$(basename "$item")" in
            .|..)
                echo "✗ 拒绝操作: $item（不会移动 . 或 ..）" >&2
                continue
                ;;
        esac
        if [ ! -e "$item" ] && [ ! -L "$item" ]; then
            echo "✗ 不存在: $item" >&2
            continue
        fi
        if [ "$interactive" -eq 1 ]; then
            printf '移入回收站 %s ? [y/N] ' "$item"
            read ans
            [ "$ans" = "y" ] || continue
        fi
        local root
        if ! root=$(_trash_pick "$item"); then
            echo "⚠ 目标盘上没有我的回收站，回退到 $root（跨盘复制，可能较慢）" >&2
        fi
        mkdir -p "$root" || { echo "✗ 无法创建回收站: $root" >&2; continue; }
        local name=$(basename "$item")
        local newname="${timestamp}_${name}"
        while [ -e "$root/$newname" ]; do
            newname="${timestamp}_${RANDOM}_${name}"
        done
        if mv "$item" "$root/$newname"; then
            echo "✓ 已移动: $item → $root/$newname"
        else
            echo "✗ 移动失败: $item（上方为 mv 的原始报错）" >&2
        fi
    done
}

# 保存原始rm命令的路径
echo -e '\talias \033[1;35mrrm\033[0m=/bin/rm'
alias rrm=/bin/rm

# 定义一个新的rm命令，它调用_del函数
echo -e '\talias \033[1;35mrm\033[0m=func_delfile'
alias rm=func_delfile

# 显示回收站中垃圾清单（所有存在的垃圾箱）
func_dellist(){
    local d
    for d in $(_trash_dirs); do
        [ -d "$d" ] || continue
        echo "=== $d ==="
        eza --no-permissions --time-style long-iso -lh --tree -L 1 --no-user "$d/"
    done
}

echo -e '\talias \033[1;35mrm.trash.show\033[0m=func_dellist'
alias rm.trash.show=func_dellist
# 找回回收站相应文件（多个垃圾箱时先选择）
func_delback(){
    local dirs=($(_trash_dirs))
    local d
    if [ ${#dirs[@]} -eq 1 ]; then
        d=$dirs[1]
    else
        local i=1 x
        for x in $dirs; do
            [ -d "$x" ] || continue
            echo "$i) $x"
            i=$((i+1))
        done
        echo "恢复到当前目录 $PWD，请选择垃圾箱编号 [1-${#dirs[@]}]"
        read n
        d=$dirs[$n]
        if [ -z "$d" ] || [ ! -d "$d" ]; then
            echo "无效选择"
            return 1
        fi
    fi
    echo "将执行 mv -i $d/* ./"
    echo "你可以自己写mv命令来恢复文件"
    echo "在那之前，建议执行rm.trash.show来检查垃圾箱的文件"
    echo "是否继续执行 [y/n]"
    read confirm
    if [ ${confirm} = "y" ]; then
        mv -i $d/* ./
    fi
}
echo -e '\talias \033[1;35mrm.trash.back\033[0m=func_delback'
alias rm.trash.back=func_delback
# 清空所有回收站
func_delclear(){
    local dirs=($(_trash_dirs))
    echo "确认删除以下回收站的所有文件？？？"
    local d
    for d in $dirs; do [ -d "$d" ] && echo "  $d"; done
    echo "[y/n]"
    read confirm
    if [ ${confirm} = "y"  ] ;then
        for d in $dirs; do
            [ -d "$d" ] || continue
            /bin/rm -rf "$d"/*
            /bin/rm -rf "$d"/.[!.]* 2> /dev/null
            echo "已清空: $d"
        done
        echo "完成"
    fi
}
echo -e '\talias \033[1;35mrm.trash.clear\033[0m=func_delclear'
alias rm.trash.clear=func_delclear
