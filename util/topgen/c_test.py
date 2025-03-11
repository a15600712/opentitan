# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""This contains a class which is used to help generate top level SW tests.

We maintain as a separate class rather than merge implementation with c.py,
because both serve different purposes and need to capture the information
differently.
"""

import logging as log
import sys
from typing import Dict
from collections import defaultdict

from reggen.ip_block import IpBlock
from reggen.interrupt import IntrType

from .c import TopGenC
from .lib import find_module, Name


class TestPeripheral:
    """Captures a peripheral instance's attributes for use in SW tests.

    It encapsulates the settings for each peripheral's instance in the design.
    These settings are captured as identifiers that are already defined in
    other autogenerated / hand-edited sources such as top_{name}.h and the DIF
    headers, rather than hard-coded constants. This is done to ensure that a
    single source of truth is referenced in all of the tests.
    """
    def __init__(self, name: str, inst_name: str, base_addr_name: str):
        self.name = name
        self.inst_name = inst_name
        self.base_addr_name = base_addr_name


class IrqTestPeripheral(TestPeripheral):
    """Captures a peripheral instance's attributes for use in IRQ test."""
    def __init__(self, name: str, inst_name: str, base_addr_name: str,
                 plic_name: str, start_irq: str, end_irq: str,
                 plic_start_irq: str, status_type_mask: int,
                 status_default_mask: int, addr_space: str):
        super().__init__(name, inst_name, base_addr_name)
        self.plic_name = plic_name
        self.start_irq = start_irq
        self.end_irq = end_irq
        self.plic_start_irq = plic_start_irq
        self.status_type_mask = status_type_mask
        self.status_default_mask = status_default_mask
        # This is used to help understand where the base address comes from.
        self.addr_space = addr_space


class AlertTestPeripheral(TestPeripheral):
    """Captures a peripheral instance's attributes for use in IRQ test."""
    def __init__(self, name: str, inst_name: str, base_addr_name: str,
                 top_alert_name: str, dif_alert_name: str, num_alerts: int,
                 addr_space: str):
        super().__init__(name, inst_name, base_addr_name)
        self.top_alert_name = top_alert_name
        self.dif_alert_name = dif_alert_name
        self.num_alerts = num_alerts
        # This is used to help understand where the base address comes from.
        self.addr_space = addr_space


class TopGenCTest(TopGenC):
    def __init__(self, top_info, name_to_block: Dict[str, IpBlock]):
        super().__init__(top_info, name_to_block)

        self.irq_peripherals = defaultdict(dict)
        self.alert_peripherals = defaultdict(dict)

        # TODO: Model alert and irq domains with explicit connectivity, and add
        # support for multiple "handler" instances in one design.
        # TODO: Don't require that the handler's module_instance_name be the
        # same as the template name.
        self.alert_handler = find_module(self.top['module'], 'alert_handler')
        self.rv_plic = find_module(self.top['module'], 'rv_plic')

        self.irq_peripherals = {
            x['name']: self._get_irq_peripherals(self.rv_plic, x['name'])
            for x in top_info['addr_spaces']
        }

        # Only generate alert_handler and mappings if there is an alert_handler
        if self.alert_handler is not None:
            self.alert_peripherals = {
                x['name']: self._get_alert_peripherals(self.alert_handler, x['name'])
                for x in top_info['addr_spaces']
            }

    def _get_irq_peripherals(self, rv_plic, addr_space):
        """For the given rv_plic instance, capture all the served peripherals
        reachable from the host(s) indicated by the address space. The
        peripherals have their interrupts connected to the PLIC instance, and
        each peripheral's interface with the interrupt CSRs must be able to be
        accessed by the host(s) to perform the tests.
        """
        irq_peripherals = []
        # TODO: Model interrupt domains with explicit connectivity, an
        # orthogonal concept to address spaces. There may be multiple PLICs, for
        # example, in one address space. Or devices with core interfaces in
        # address spaces that are different from the CPU's and PLIC's.
        rv_plic_addr_spaces = rv_plic['base_addrs'][None]
        if addr_space not in rv_plic_addr_spaces:
            return irq_peripherals

        device_regions = self.all_device_regions()
        # TODO: We only know how to directly access irq test CSRs in this
        # address space. A host could still reach other devices via a bridge,
        # but bridges may not be transparent and may need setup code.
        direct_device_regions = device_regions[addr_space]
        for entry in self.top['module']:
            inst_name = entry['name']
            if inst_name not in self.top["interrupt_module"]:
                continue

            name = entry['type']
            plic_name = (self._top_name + Name(["plic", "peripheral"]) +
                         Name.from_snake_case(inst_name))
            plic_name = plic_name.as_c_enum()

            # Device regions may have multiple TL interfaces. Pick the region
            # associated with the 'core' interface.
            # TODO: Model interrupt domains with explicit connectivity. This
            # method of associating interrupts with a PLIC leads to inflexible
            # architectures that do not cover all use cases.
            if_name = 'core'
            periph_addr_space = addr_space
            if inst_name in direct_device_regions:
                if len(direct_device_regions[inst_name]) == 1:
                    if_name = list(direct_device_regions[inst_name].keys())[0]
                try:
                    region = direct_device_regions[inst_name][if_name]
                except KeyError:
                    log.error(f"The 'base_addrs' dict for {name} needs to have "
                              "one entry keyed with 'None' or 'core'.")
                    sys.exit(1)
                base_addr_name = region.base_addr_name().as_c_define()
            else:
                block = self._name_to_block[name]
                if_names = list(block.reg_blocks.keys())
                if len(if_names) == 1:
                    if_name = if_names[0]
                base_addr_name = None

                for region_addr_space, regions in device_regions.items():
                    if (inst_name in regions) and if_name in regions[inst_name]:
                        region = regions[inst_name][if_name]
                        base_addr_name = region.base_addr_name().as_c_define()
                        periph_addr_space = region_addr_space
                        break

                if base_addr_name is None:
                    log.error(f"The 'base_addrs' dict for {name} needs to have "
                              "one entry keyed with 'None' or 'core'.")
                    sys.exit(1)

            plic_name = (self._top_name + Name(["plic", "peripheral"]) +
                         Name.from_snake_case(inst_name))
            plic_name = plic_name.as_c_enum()

            start_irq = self.device_irqs[inst_name][0]
            end_irq = self.device_irqs[inst_name][-1]
            plic_start_irq = (self._top_name + Name(["plic", "irq", "id"]) +
                              Name.from_snake_case(start_irq))
            plic_start_irq = plic_start_irq.as_c_enum()

            # Get DIF compliant, instance-agnostic IRQ names.
            start_irq = start_irq.replace(inst_name, f"dif_{name}_irq", 1)
            start_irq = Name.from_snake_case(start_irq).as_c_enum()
            end_irq = end_irq.replace(inst_name, f"dif_{name}_irq", 1)
            end_irq = Name.from_snake_case(end_irq).as_c_enum()

            # Create two sets of masks:
            # - status_type_mask encodes whether an IRQ is of status type
            # - status_default_mask encodes default of status type IRQ
            n = 0
            status_type_mask = 0
            status_default_mask = 0
            for irq in self.top["interrupt"]:
                if irq["module_name"] == inst_name:
                    if irq["intr_type"] == IntrType.Status:
                        setbit = (((1 << irq["width"]) - 1) << n)
                        status_type_mask |= setbit
                        if irq["default_val"] is True:
                            status_default_mask |= setbit
                    n += irq["width"]

            irq_peripheral = IrqTestPeripheral(name, inst_name, base_addr_name,
                                               plic_name, start_irq, end_irq,
                                               plic_start_irq, status_type_mask,
                                               status_default_mask,
                                               periph_addr_space)
            irq_peripherals.append(irq_peripheral)

        irq_peripherals.sort(key=lambda p: p.inst_name)
        return irq_peripherals

    def _get_alert_peripherals(self, alert_handler, addr_space):
        """For the given alert_handler instance, capture all the served
        peripherals reachable from the host(s) indicated by the address space.
        The peripherals have their alerts connected to the alert handler
        instance, and each peripheral's interface with the alert test CSR must
        be able to be accessed by the host(s) to perform the tests.
        """
        alert_peripherals = []
        # TODO: Model alert domains with explicit connectivity
        alert_handler_addr_spaces = alert_handler['base_addrs'][None]
        if addr_space not in alert_handler_addr_spaces:
            return alert_peripherals
        all_device_regions = self.all_device_regions()
        all_direct_regions = all_device_regions[addr_space]
        for entry in self.top['module']:
            inst_name = entry['name']
            if inst_name not in self.top["alert_module"]:
                continue

            if not entry['generate_dif']:
                continue

            name = entry['type']
            periph_addr_space = addr_space
            region = None
            # Prioritized list of interface names to try.
            # TODO: This is an implicit assignment of alerts to reg interfaces
            # that is fraught with pitfalls.
            if_list = ["core", "regs", "cfg", None]
            if inst_name in all_direct_regions:
                regions = all_direct_regions[inst_name]
                # TODO: This may not work with bus bridges present.
                for if_name in if_list:
                    if if_name in regions:
                        region = regions[if_name]
                        break
            if region is None:
                all_inst_regions = {k: v for (k, v) in all_device_regions.items()
                                    if inst_name in v}
                # Try other address spaces.
                for region_addr_space, regions in all_inst_regions.items():
                    inst_regions = regions[inst_name]
                    for if_name in if_list:
                        if if_name in inst_regions:
                            periph_addr_space = region_addr_space
                            region = inst_regions[if_name]
                            break
                    if region is not None:
                        break
            if region is None:
                log.error(f"Could not find supported reg interface for alerts "
                          f"coming from module {name}")
                sys.exit(1)
            base_addr_name = region.base_addr_name().as_c_define()

            # If alerts are routed to the external interface, there is no need for DIFs, etc ...
            if 'outgoing_alert' in entry:
                continue

            dif_alert_name = self.device_alerts[inst_name][0]
            num_alerts = len(self.device_alerts[inst_name])

            top_alert_name = (self._top_name +
                              Name(["Alert", "Id"]) +
                              Name.from_snake_case(dif_alert_name))
            top_alert_name = top_alert_name.as_c_enum()

            # Get DIF compliant, instance-agnostic alert names.
            dif_alert_name = dif_alert_name.replace(inst_name, f"dif_{name}_alert", 1)
            dif_alert_name = Name.from_snake_case(dif_alert_name).as_c_enum()

            alert_peripheral = AlertTestPeripheral(name, inst_name, base_addr_name,
                                                   top_alert_name, dif_alert_name,
                                                   num_alerts, periph_addr_space)
            alert_peripherals.append(alert_peripheral)

        alert_peripherals.sort(key=lambda p: p.inst_name)
        return alert_peripherals
