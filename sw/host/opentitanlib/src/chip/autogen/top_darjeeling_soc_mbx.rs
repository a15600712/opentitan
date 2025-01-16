// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This file was generated automatically.
// Please do not modify content of this file directly.
// File generated by using template: "toplevel.rs.tpl"
// To regenerate this file follow OpenTitan topgen documentations.

#![allow(dead_code)]

//! This file contains enums and consts for use within the Rust codebase.
//!
//! These definitions are for information that depends on the top-specific chip
//! configuration, which includes:
//! - Device Memory Information (for Peripherals and Memory)
//! - PLIC Interrupt ID Names and Source Mappings
//! - Alert ID Names and Source Mappings

use core::convert::TryFrom;

/// Peripheral base address for soc device on mbx0 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX0_SOC_BASE_ADDR: usize = 0x1465000;

/// Peripheral size for soc device on mbx0 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX0_SOC_BASE_ADDR and
/// `MBX0_SOC_BASE_ADDR + MBX0_SOC_SIZE_BYTES`.
pub const MBX0_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx1 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX1_SOC_BASE_ADDR: usize = 0x1465100;

/// Peripheral size for soc device on mbx1 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX1_SOC_BASE_ADDR and
/// `MBX1_SOC_BASE_ADDR + MBX1_SOC_SIZE_BYTES`.
pub const MBX1_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx2 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX2_SOC_BASE_ADDR: usize = 0x1465200;

/// Peripheral size for soc device on mbx2 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX2_SOC_BASE_ADDR and
/// `MBX2_SOC_BASE_ADDR + MBX2_SOC_SIZE_BYTES`.
pub const MBX2_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx3 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX3_SOC_BASE_ADDR: usize = 0x1465300;

/// Peripheral size for soc device on mbx3 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX3_SOC_BASE_ADDR and
/// `MBX3_SOC_BASE_ADDR + MBX3_SOC_SIZE_BYTES`.
pub const MBX3_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx4 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX4_SOC_BASE_ADDR: usize = 0x1465400;

/// Peripheral size for soc device on mbx4 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX4_SOC_BASE_ADDR and
/// `MBX4_SOC_BASE_ADDR + MBX4_SOC_SIZE_BYTES`.
pub const MBX4_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx5 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX5_SOC_BASE_ADDR: usize = 0x1465500;

/// Peripheral size for soc device on mbx5 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX5_SOC_BASE_ADDR and
/// `MBX5_SOC_BASE_ADDR + MBX5_SOC_SIZE_BYTES`.
pub const MBX5_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx6 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX6_SOC_BASE_ADDR: usize = 0x1465600;

/// Peripheral size for soc device on mbx6 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX6_SOC_BASE_ADDR and
/// `MBX6_SOC_BASE_ADDR + MBX6_SOC_SIZE_BYTES`.
pub const MBX6_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx_pcie0 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX_PCIE0_SOC_BASE_ADDR: usize = 0x1460100;

/// Peripheral size for soc device on mbx_pcie0 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX_PCIE0_SOC_BASE_ADDR and
/// `MBX_PCIE0_SOC_BASE_ADDR + MBX_PCIE0_SOC_SIZE_BYTES`.
pub const MBX_PCIE0_SOC_SIZE_BYTES: usize = 0x20;

/// Peripheral base address for soc device on mbx_pcie1 in top darjeeling.
///
/// This should be used with #mmio_region_from_addr to access the memory-mapped
/// registers associated with the peripheral (usually via a DIF).
pub const MBX_PCIE1_SOC_BASE_ADDR: usize = 0x1460200;

/// Peripheral size for soc device on mbx_pcie1 in top darjeeling.
///
/// This is the size (in bytes) of the peripheral's reserved memory area. All
/// memory-mapped registers associated with this peripheral should have an
/// address between #MBX_PCIE1_SOC_BASE_ADDR and
/// `MBX_PCIE1_SOC_BASE_ADDR + MBX_PCIE1_SOC_SIZE_BYTES`.
pub const MBX_PCIE1_SOC_SIZE_BYTES: usize = 0x20;
