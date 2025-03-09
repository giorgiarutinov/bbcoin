# Copyright (c) 2023-present The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or https://opensource.org/license/mit/.

function(generate_setup_nsi)
  set(abs_top_srcdir ${PROJECT_SOURCE_DIR})
  set(abs_top_builddir ${PROJECT_BINARY_DIR})
  set(CLIENT_URL ${PROJECT_HOMEPAGE_URL})
  set(CLIENT_TARNAME "bbcoin")
  set(BITCOIN_GUI_NAME "bbcoin-qt")
  set(BITCOIN_DAEMON_NAME "bbcoind")
  set(BITCOIN_CLI_NAME "bbcoin-cli")
  set(BITCOIN_TX_NAME "bbcoin-tx")
  set(BITCOIN_WALLET_TOOL_NAME "bbcoin-wallet")
  set(BITCOIN_TEST_NAME "test_bbcoin")
  set(EXEEXT ${CMAKE_EXECUTABLE_SUFFIX})
  configure_file(${PROJECT_SOURCE_DIR}/share/setup.nsi.in ${PROJECT_BINARY_DIR}/bbcoin-win64-setup.nsi USE_SOURCE_PERMISSIONS @ONLY)
endfunction()
