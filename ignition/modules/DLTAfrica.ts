import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DLTAfricaModule = buildModule("DLTAfricaModule", (m) => {
  const dltAfrica = m.contract("DLTAfricaToken");

  return { dltAfrica };
});

export default DLTAfricaModule;
