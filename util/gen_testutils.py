#!/usr/bin/env python3
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""autogen_testutils.py is a script for auto-generating a portion of the
`testutils` libraries from Mako templates.

`testutils` libraries are testing libraries that sit a layer above the DIFs
that aid in writing chip-level tests by enabling test developers to re-use
code that calls a specific collection of DIFs.

To render all testutil templates, run the script with:
$ util/autogen_testutils.py
"""

import subprocess
import argparse
import logging
import sys
import tempfile
import shutil
from pathlib import Path

import hjson

import topgen.lib as topgen_lib
from autogen_testutils.gen import gen_testutils
from make_new_dif.ip import Ip

# This file is $REPO_TOP/util/autogen_testutils.py, so it takes two parent()
# calls to get back to the top.
REPO_TOP = Path(__file__).resolve().parent.parent


def main():
    # Parse command line args.
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--topcfg",
        "-t",
        type=Path,
        required=True,
        help="path of the top hjson file.",
    )
    parser.add_argument(
        "--ipcfg",
        "-i",
        type=Path,
        action="append",
        default=[],
        help="path of an IP hjson file (if not specified, will be guessed by the tool).",
    )
    parser.add_argument(
        "--outdir",
        "-o",
        type=Path,
        help="Output directory"
    )
    parser.add_argument(
        "--clang-format",
        default=None,
        help="Path to clang-format. If not provided, the tool will invoke it through bazelisk.sh"
    )
    args = parser.parse_args()

    logging.basicConfig()
    # Parse toplevel Hjson to get IPs that are generated with IPgen.
    try:
        topcfg_text = args.topcfg.read_text()
    except FileNotFoundError:
        logging.error(f"hjson {args.topcfg} could not be found.")
        sys.exit(1)
    topcfg = hjson.loads(topcfg_text, use_decimal=True)

    # Define autogen DIF directory.
    outdir = args.outdir if args.outdir else REPO_TOP / "sw/device/lib/testing/autogen"

    # First load provided IPs.
    ip_hjson = {}
    for ipcfg in args.ipcfg:
        # Assume that the file name is "<ip>.hjson"
        ipname = ipcfg.stem
        ip_hjson[ipname] = ipcfg

    # Create list of IPs to generate shared testutils code for. This is all IPs
    # that have a DIF library, that the testutils functions can use. Note, the
    # templates will take care of only generating ISR testutil functions for IPs
    # that can actually generate interrupts.
    ips = []
    for ipname in list({m['type'] for m in topcfg['module']}):
        # If the IP's hjson path was not provided on the command line, guess
        # its location based on the type and top name.
        if ipname in ip_hjson:
            hjson_file = ip_hjson[ipname]
        else:
            hjson_file = topgen_lib.get_ip_hjson_path(ipname, topcfg, REPO_TOP)
            logging.warning("IP hjson path for {} was not provided, ".format(ipname) +
                            "guessed location: {}".format(hjson_file.relative_to(REPO_TOP)))

        # NOTE: ip.name_long_* not needed for auto-generated files which
        # are the only files (re-)generated in batch mode.
        ips.append(Ip(ipname, "AUTOGEN", hjson_file))

    # Auto-generate testutils files.
    testutilses = gen_testutils(outdir, topcfg, ips)

    # Format autogenerated file with clang-format.
    try:
        if not args.clang_format:
            subprocess.check_call(
                ["./bazelisk.sh", "run", "//quality:clang_format_fix", "--"] + testutilses
            )
        else:
            for file in testutilses:
                with tempfile.NamedTemporaryFile() as tmpfile:
                    subprocess.check_call(
                        [args.clang_format, file],
                        stdout = tmpfile,
                    )
                    shutil.copyfile(tmpfile.name, file)
    except subprocess.CalledProcessError:
        logging.error(
            f"failed to format {testutilses} with clang-format.")
        sys.exit(1)


if __name__ == "__main__":
    main()
