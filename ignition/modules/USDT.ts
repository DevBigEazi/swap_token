import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const USDTModule = buildModule("USDTModule", (m) => {
  const usdt = m.contract("USDTToken");

  return { usdt };
});

export default USDTModule;
