#!/usr/bin/env python3
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
r"""Top Module Documentation Generator
"""
from tabulate import tabulate

from .lib import find_module

TABLE_HEADER = '''<!--
DO NOT EDIT THIS FILE DIRECTLY.
It has been generated with the following command:
{}
-->
'''


def set_md_table_font_size(row, size):
    """Wrap each row element with HTML tags and specify font size"""
    for k, elem in enumerate(row):
        row[k] = '<p style="font-size:' + str(size) + '">' + elem + '</p>'
    return row


def create_pinout_table(top, c_helper, target):
    """Create the pinout table for a specific target and extract some stats"""
    header = [
        "Pad Name", "Type", "Bank", "Connection", "Special Function",
        "Pinmux Insel Constant / Muxed Output Index", "Description"
    ]
    table_rows = [set_md_table_font_size(header, "smaller")]
    colalign = ("center", ) * len(header)

    # Pad stats
    stats = {}
    stats['muxed'] = 0
    stats['direct'] = 0
    stats['manual'] = 0

    # get all pads for this target
    pads = top['pinout']['pads'] + target['pinout']['add_pads']
    remove_ports = target['pinout']['remove_ports']
    remove_pads = target['pinout']['remove_pads']
    special_signals = target['pinmux']['special_signals']

    # map pad names to special function signals
    special_pads = {}
    for sig in special_signals:
        special_pads.update(
            {sig['pad']: {
                'name': sig['name'],
                'desc': sig['desc']
            }})

    i = 2  # insel enum starts at 2
    j = 0  # mio_out enum starts at 0
    for pad in pads:
        # get the corresponding insel constant and MIO output index
        if pad['connection'] == 'muxed':
            name, _, _ = c_helper.pinmux_insel.constants[i]
            insel = name.as_c_enum()
            name, _, _ = c_helper.pinmux_mio_out.constants[j]
            mio_out = name.as_c_enum()
            i += 1
            j += 1
        else:
            insel = "-"
            mio_out = "-"
        # check whether this pad/port needs to be dropped
        if pad['name'] in remove_ports:
            continue
        if pad['name'] in remove_pads:
            continue
        # gather some stats
        stats[pad['connection']] += 1
        # annotate special functions
        if pad['name'] in special_pads:
            special_func = special_pads[pad['name']]['name']
            desc = pad['desc'] + " / " + special_pads[pad['name']]['desc']
        else:
            special_func = "-"
            desc = pad['desc']
        row = [
            pad['name'], pad['type'], pad['bank'], pad['connection'],
            special_func, insel + ' / ' + mio_out, desc
        ]
        table_rows.append(set_md_table_font_size(row, "smaller"))

    ret_str = tabulate(table_rows,
                       headers="firstrow",
                       tablefmt="pipe",
                       colalign=colalign)

    return ret_str, stats


def create_pinmux_table(top, c_helper):
    """Create the pinmux connectivity table"""
    header = [
        "Module / Signal", "Connection", "Pad",
        "Pinmux Outsel Constant / Peripheral Input Index", "Description"
    ]
    table_rows = [set_md_table_font_size(header, "smaller")]
    colalign = ("center", ) * len(header)

    i = 3  # outsel enum starts at 3
    j = 0  # periph_input enum starts at 0
    for sig in top['pinmux']['ios']:
        port = sig['name']
        if sig['width'] > 1:
            port += '[' + str(sig['idx']) + ']'
        pad = sig['pad'] if sig['pad'] else '-'
        # get the corresponding insel constant
        if sig['connection'] == 'muxed' and sig['type'] in ['inout', 'output']:
            name, _, _ = c_helper.pinmux_outsel.constants[i]
            outsel = name.as_c_enum()
            i += 1
        else:
            outsel = "-"
        # get the corresponding peripheral input index
        if sig['connection'] == 'muxed' and sig['type'] in ['inout', 'input']:
            name, _, _ = c_helper.pinmux_peripheral_in.constants[j]
            periph_in = name.as_c_enum()
            j += 1
        else:
            periph_in = "-"
        row = [
            port, sig['connection'], pad, outsel + " / " + periph_in,
            sig['desc']
        ]
        table_rows.append(set_md_table_font_size(row, "smaller"))

    return tabulate(table_rows,
                    headers="firstrow",
                    tablefmt="pipe",
                    colalign=colalign)


def gen_pinmux_docs(top, c_helper, out_path):
    """Generate pinmux/pinout summary table and linked pinout subtables for each target.

    All files are placed in the top's ip_autogen/pinmux/doc directory.
    e.g.
    <out_path>
    └── ip_autogen
        └── pinmux
            └── doc
                ├── pinout_asic.md    # subtable
                ├── pinout_cw310.md   # subtable
                ├── pinout_cw340.md   # subtable
                └── targets.md        # Summary table
    """

    # 'out_path' is the top-level directory for a generated top (e.g. hw/top_earlgrey)
    pinmux_top_doc_path = out_path / 'ip_autogen' / 'pinmux' / 'doc'
    pinmux_top_doc_path.mkdir(parents=True, exist_ok=True)

    gencmd = ("util/topgen.py -t hw/top_{topname}/data/top_{topname}.hjson "
              "-o hw/top_{topname}/".format(topname=top['name']))

    header = [
        "Target Name", "#IO Banks", "#Muxed Pads", "#Direct Pads",
        "#Manual Pads", "#Total Pads", "Pinout / Pinmux Tables"
    ]
    table_rows = [header]
    colalign = ("center", ) * len(header)

    # Create subtables for each pinout target, plus a row in the summary table
    for target in top['targets']:
        name = target['name']
        pinout_name = f"pinout_{name}.md"
        table_str, stats = create_pinout_table(top, c_helper, target)

        # create file with pinout+pinmux subtable for this target
        pinout_table = (
            f'# "{name.upper()}" Target : Pinout and Pinmux Connectivity\n')
        pinout_table += TABLE_HEADER.format(gencmd)
        pinout_table += '## Pinout Table\n\n'
        pinout_table += table_str + '\n'
        pinout_table += '## Pinmux Connectivity\n\n'
        pinout_table += create_pinmux_table(top, c_helper)
        pinout_table += "\n"
        pinout_table_path = pinmux_top_doc_path / pinout_name
        pinout_table_path.write_text(pinout_table)

        # create summary table row
        row = [
            name.upper(),  # target name
            len(top['pinout']['banks']),  # io banks
            stats['muxed'],  # muxed pads
            stats['direct'],  # direct pads
            stats['manual'],  # manual pads
            stats['muxed'] + stats['direct'] + stats['manual'],  # total pads
            # subtable, in same dir as the summary table
            f"[Pinout Table](./{pinout_name})"
        ]
        table_rows.append(row)

    # Now create the summary table
    summary_table = f'# "top_{top["name"]}" Pinmux Targets\n'
    summary_table += TABLE_HEADER.format(gencmd)
    summary_table += tabulate(table_rows,
                              headers="firstrow",
                              tablefmt="pipe",
                              colalign=colalign)
    summary_table += "\n"
    summary_table_path = pinmux_top_doc_path / "targets.md"
    summary_table_path.write_text(summary_table)


def gen_top_docs(top, c_helper, out_path):
    if find_module(top['module'], 'pinmux'):
        # create pinout / pinmux specific tables for all targets
        gen_pinmux_docs(top, c_helper, out_path)
