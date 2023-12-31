//! Blinks the LED on a Pico board
//!
//! This will blink an LED attached to GP25, which is the pin the Pico uses for the on-board LED.
#![no_std]
#![no_main]

use cortex_m_rt::entry;
use defmt::*;
use defmt_rtt as _;
use embedded_hal::digital::v2::OutputPin;
use embedded_hal::prelude::*;
use embedded_time::fixed_point::FixedPoint;
use panic_probe as _;

// Provide an alias for our BSP so we can switch targets quickly.
// Uncomment the BSP you included in Cargo.toml, the rest of the code does not need to change.
use rp_pico as bsp;
// use sparkfun_pro_micro_rp2040 as bsp;

use embedded_hal::spi::MODE_1;
use embedded_time::rate::*;

use bsp::hal::{
    clocks::{init_clocks_and_plls, Clock},
    gpio::FunctionSpi,
    pac, spi,
    watchdog::Watchdog,
    Sio,
};

// For rust-analyzer we disable the #[entry] macro
#[cfg_attr(not(test), entry)]
fn main() -> ! {
    info!("Program start");
    let mut pac = pac::Peripherals::take().unwrap();
    let core = pac::CorePeripherals::take().unwrap();
    let mut watchdog = Watchdog::new(pac.WATCHDOG);
    let sio = Sio::new(pac.SIO);

    // External high-speed crystal on the pico board is 12Mhz
    let external_xtal_freq_hz = 12_000_000u32;

    let clocks = init_clocks_and_plls(
        external_xtal_freq_hz,
        pac.XOSC,
        pac.CLOCKS,
        pac.PLL_SYS,
        pac.PLL_USB,
        &mut pac.RESETS,
        &mut watchdog,
    )
    .ok()
    .unwrap();

    let pins = bsp::Pins::new(
        pac.IO_BANK0,
        pac.PADS_BANK0,
        sio.gpio_bank0,
        &mut pac.RESETS,
    );

    let mut led_pin = pins.led.into_push_pull_output();

    let mut cs_pin = pins.gpio17.into_push_pull_output();
    let _ = pins.gpio18.into_mode::<FunctionSpi>();
    let _ = pins.gpio19.into_mode::<FunctionSpi>();

    let mut delay = cortex_m::delay::Delay::new(core.SYST, clocks.system_clock.freq().integer());

    let spi = spi::Spi::<_, _, 8>::new(pac.SPI0);

    let mut spi = spi.init(
        &mut pac.RESETS,
        clocks.peripheral_clock.freq(),
        16_000_000u32.Hz(),
        &MODE_1,
    );

    let gain_command = [
        0b00000100,
        0b00000001,
        0b00000001,
    ];

    let command = [
        0b00001000,
        0b11111111,
        0b11111111,
    ];

    // TODO: we might have to do that after some delay to give the dac time to initialize
    cs_pin.set_low().unwrap();
    spi.write(&gain_command).unwrap();
    cs_pin.set_high().unwrap();

    loop {
        info!("on!");
        led_pin.set_high().unwrap();
        delay.delay_ms(500);
        info!("off!");
        led_pin.set_low().unwrap();
        cs_pin.set_low().unwrap();
        spi.write(&command).unwrap();
        cs_pin.set_high().unwrap();
        delay.delay_ms(500);
    }
}

// End of file
