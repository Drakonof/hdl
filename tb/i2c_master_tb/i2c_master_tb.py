#!/usr/bin/python

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class I2c_master_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 10, units="ns").start())

    async def clock_tick(self):
        await RisingEdge(self.dut.clk_i)
        
    async def reset(self):
        self.dut.s_rst_n_i.value = 0
        await RisingEdge(self.dut.clk_i)
        self.dut.s_rst_n_i.value = 1

    async def start(self):
        self.dut.en_i.value = 1
        self.dut.prescale_i.value = 8
        self.dut.sda_i.value = 0
        self.dut.stop_i.value = 0

    async def stop(self):
        self.dut.stop_i.value = 1
        for addr in range(100):
            await RisingEdge(self.dut.clk_i)

    async def send_addr(self, addr, rw):
        self.dut.slave_addr_i.value = addr
        self.dut.dir_i.value = rw

    async def send_data(self, data):
        self.dut.data_i.value = data
        self.dut.write_i.value = 1

        while True:
            await RisingEdge(self.dut.clk_i)
            if self.dut.status_o.value == 1:
                break

    async def check_start(self, rnge):
        for addr in range(rnge):
            await RisingEdge(self.dut.clk_i)


@cocotb.test()
async def main(dut):
    tb = I2c_master_tb(dut)


    cocotb.log.info("Start of simulation")

    await tb.reset()
    await tb.start()
    await tb.send_addr(0x58, 0)
    await tb.send_data(0x64)
    await tb.send_data(0x65)
    await tb.send_data(0x66)
    await tb.send_data(0x67)
    await tb.stop()
    await Timer(100, units='ns')

    cocotb.log.info("End of simulation")


if __name__ == "__main__":
    sys.exit(main())
