import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const LockModule = buildModule("SwapModule", (m) => {

  const swap = m.contract("SwapToken");

  return { swap };
});

export default LockModule;
