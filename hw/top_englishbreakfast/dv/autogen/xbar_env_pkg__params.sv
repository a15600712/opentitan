// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `topgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"rom_ctrl__rom", '{
        '{32'h00008000, 32'h0000ffff}
    }},
    '{"rom_ctrl__regs", '{
        '{32'h411e0000, 32'h411e007f}
    }},
    '{"flash_ctrl__core", '{
        '{32'h41000000, 32'h410001ff}
    }},
    '{"flash_ctrl__prim", '{
        '{32'h41008000, 32'h4100807f}
    }},
    '{"flash_ctrl__mem", '{
        '{32'h20000000, 32'h2000ffff}
    }},
    '{"aes", '{
        '{32'h41100000, 32'h411000ff}
    }},
    '{"rv_plic", '{
        '{32'h48000000, 32'h4fffffff}
    }},
    '{"rv_core_ibex__cfg", '{
        '{32'h411f0000, 32'h411f00ff}
    }},
    '{"sram_ctrl_main__regs", '{
        '{32'h411c0000, 32'h411c003f}
    }},
    '{"sram_ctrl_main__ram", '{
        '{32'h10000000, 32'h1001ffff}
    }},
    '{"uart0", '{
        '{32'h40000000, 32'h4000003f}
    }},
    '{"uart1", '{
        '{32'h40010000, 32'h4001003f}
    }},
    '{"gpio", '{
        '{32'h40040000, 32'h4004007f}
    }},
    '{"spi_device", '{
        '{32'h40050000, 32'h40051fff}
    }},
    '{"spi_host0", '{
        '{32'h40060000, 32'h4006003f}
    }},
    '{"rv_timer", '{
        '{32'h40100000, 32'h401001ff}
    }},
    '{"usbdev", '{
        '{32'h40320000, 32'h40320fff}
    }},
    '{"pwrmgr_aon", '{
        '{32'h40400000, 32'h4040007f}
    }},
    '{"rstmgr_aon", '{
        '{32'h40410000, 32'h4041007f}
    }},
    '{"clkmgr_aon", '{
        '{32'h40420000, 32'h4042007f}
    }},
    '{"pinmux_aon", '{
        '{32'h40460000, 32'h40460fff}
    }},
    '{"ast", '{
        '{32'h40480000, 32'h404803ff}
    }}};

  // List of Xbar hosts
tl_host_t xbar_hosts[$] = '{
    '{"rv_core_ibex__corei", 0, '{
        "rom_ctrl__rom",
        "sram_ctrl_main__ram",
        "flash_ctrl__mem"}}
    ,
    '{"rv_core_ibex__cored", 1, '{
        "rom_ctrl__rom",
        "rom_ctrl__regs",
        "sram_ctrl_main__ram",
        "flash_ctrl__mem",
        "uart0",
        "uart1",
        "gpio",
        "spi_device",
        "spi_host0",
        "rv_timer",
        "usbdev",
        "pwrmgr_aon",
        "rstmgr_aon",
        "clkmgr_aon",
        "pinmux_aon",
        "ast",
        "flash_ctrl__core",
        "flash_ctrl__prim",
        "aes",
        "rv_plic",
        "sram_ctrl_main__ram",
        "sram_ctrl_main__regs",
        "rv_core_ibex__cfg"}}
};
