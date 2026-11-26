#!/usr/bin/env zsh

TEST_DIR="${0:A:h}"
REPO_DIR="${TEST_DIR:h}"
source "${TEST_DIR}/testlib.sh"

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-text contains unexpected value}"
    case "$haystack" in
        *"$needle"*) fail_test "$message: found '$needle'" ;;
    esac
}

make_trash_fixture() {
    TEST_TMP=$(mktemp -d)
    mkdir -p "${TEST_TMP}/home" "${TEST_TMP}/data"
    TRASH_DIR="${TEST_TMP}/home/.mytrash"
    TRASH_DIRS=("$TRASH_DIR")
    source "${REPO_DIR}/zsh/trash.zsh" >/dev/null 2>&1
}

cleanup_fixture() {
    /bin/rm -rf "$TEST_TMP"
}

test_same_device_trash_is_selected() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    mkdir -p "${TEST_TMP}/data/sub"

    local picked
    picked=$(_trash_pick "${TEST_TMP}/data/sub")
    assert_eq "$TRASH_DIR" "$picked" "same-device trash should be picked"
}

test_missing_candidate_falls_back_to_trash() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    TRASH_DIRS=("${TEST_TMP}/no-such-parent/.mytrash")
    mkdir -p "${TEST_TMP}/data/sub"

    local picked rc
    picked=$(_trash_pick "${TEST_TMP}/data/sub")
    rc=$?
    assert_eq "${TEST_TMP}/no-such-parent/.mytrash" "$picked" "fallback should use the first TRASH_DIRS entry"
    assert_eq "1" "$rc" "fallback should report no same-device match"
}

test_flags_are_ignored() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    echo x > "${TEST_TMP}/data/a.txt"

    func_delfile -rf "${TEST_TMP}/data/a.txt" >/dev/null

    [ ! -e "${TEST_TMP}/data/a.txt" ] || fail_test "target should be moved"
    local count
    count=$(ls -A "$TRASH_DIR" | /usr/bin/grep -c '_a\.txt$')
    assert_eq "1" "$count" "exactly one trash entry expected"
}

test_dot_and_dotdot_are_refused() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    cd "${TEST_TMP}/data" || fail_test "cannot enter fixture"
    echo keep > sentinel

    local out_dot out_dotdot
    out_dot=$(func_delfile . 2>&1)
    out_dotdot=$(func_delfile .. 2>&1)

    assert_contains "$out_dot" "拒绝操作" "dot should be refused"
    assert_contains "$out_dotdot" "拒绝操作" "dotdot should be refused"
    [ -f sentinel ] || fail_test "fixture must stay intact"
}

test_missing_target_is_reported() {
    make_trash_fixture
    trap cleanup_fixture EXIT

    local out
    out=$(func_delfile "${TEST_TMP}/data/nope" 2>&1)
    assert_contains "$out" "不存在" "missing target should be reported"
}

test_mv_failure_is_not_reported_as_success() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    echo x > "${TEST_TMP}/data/b.txt"

    mv() { return 1 }
    local out
    out=$(func_delfile "${TEST_TMP}/data/b.txt" 2>&1)
    unset -f mv

    assert_contains "$out" "移动失败" "mv failure should be reported"
    assert_not_contains "$out" "已移动" "mv failure must not print success"
}

test_trash_dirs_lists_existing_only() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    mkdir -p "$TRASH_DIR"
    TRASH_DIRS=("$TRASH_DIR" "${TEST_TMP}/no-such-parent/.mytrash")

    local out
    out=$(_trash_dirs)
    assert_eq "$TRASH_DIR" "$out" "only existing trash dirs should be listed"
}

test_restore_moves_files_back() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    mkdir -p "$TRASH_DIR" "${TEST_TMP}/data"
    echo restored > "${TEST_TMP}/data/restored.txt"
    func_delfile "${TEST_TMP}/data/restored.txt" >/dev/null
    cd "${TEST_TMP}/data" || fail_test "cannot enter fixture"

    printf 'y\n' | func_delback >/dev/null 2>&1

    local count
    count=$(ls -A "${TEST_TMP}/data" | /usr/bin/grep -c '_restored\.txt$')
    assert_eq "1" "$count" "file should be restored (trash name retained)"
}

test_clear_empties_trash() {
    make_trash_fixture
    trap cleanup_fixture EXIT
    mkdir -p "$TRASH_DIR"
    echo junk > "${TEST_TMP}/data/junk.txt"
    func_delfile "${TEST_TMP}/data/junk.txt" >/dev/null

    printf 'y\n' | func_delclear >/dev/null 2>&1

    local left
    left=$(ls -A "$TRASH_DIR" | wc -l | tr -d ' ')
    assert_eq "0" "$left" "trash should be empty after clear"
}

run_test 'same-device trash is selected' test_same_device_trash_is_selected
run_test 'missing candidate falls back to TRASH' test_missing_candidate_falls_back_to_trash
run_test 'rm flags are ignored' test_flags_are_ignored
run_test 'dot and dotdot are refused' test_dot_and_dotdot_are_refused
run_test 'missing target is reported' test_missing_target_is_reported
run_test 'mv failure is reported as failure' test_mv_failure_is_not_reported_as_success
run_test 'trash dirs lists existing only' test_trash_dirs_lists_existing_only
run_test 'restore moves files back' test_restore_moves_files_back
run_test 'clear empties trash' test_clear_empties_trash

finish_tests
