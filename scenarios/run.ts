import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

import { createPublicClient, createWalletClient, defineChain, http } from "viem";
import { mnemonicToAccount } from "viem/accounts";

import { prepareTrade } from "./trade.js";
import type { DeploymentManifest } from "./types.js";

const root = resolve(import.meta.dirname, "..");
const manifestPath = resolve(root, ".devnet/deployment.json");
const reportPath = resolve(root, "reports/devnet.json");
const mnemonic =
  process.env.DEVNET_MNEMONIC ??
  "test test test test test test test test test test test junk";
const traderCount = Number(process.env.TRADER_COUNT ?? "100");
const concurrency = Number(process.env.TRADER_CONCURRENCY ?? "10");

if (!Number.isInteger(traderCount) || traderCount < 1 || traderCount > 100) {
  throw new Error("TRADER_COUNT must be an integer from 1 to 100");
}
if (!Number.isInteger(concurrency) || concurrency < 1 || concurrency > traderCount) {
  throw new Error("TRADER_CONCURRENCY must be between 1 and TRADER_COUNT");
}

const manifest = JSON.parse(await readFile(manifestPath, "utf8")) as DeploymentManifest;
const chain = defineChain({
  id: manifest.chainId,
  name: "v4hook devnet",
  nativeCurrency: { name: "Dev Ether", symbol: "dETH", decimals: 18 },
  rpcUrls: { default: { http: [manifest.rpcUrl] } },
});
const publicClient = createPublicClient({ chain, transport: http(manifest.rpcUrl) });

if (await publicClient.getChainId() !== manifest.chainId) {
  throw new Error("deployment manifest chainId does not match the devnet");
}

const results: Array<{ index: number; address: string; hash: string; gasUsed: string }> = [];
let nextIndex = 0;

async function worker(): Promise<void> {
  while (true) {
    const index = nextIndex++;
    if (index >= traderCount) return;

    const account = mnemonicToAccount(mnemonic, { addressIndex: index });
    const walletClient = createWalletClient({ account, chain, transport: http(manifest.rpcUrl) });
    const trade = await prepareTrade({ account, index, manifest, publicClient });
    const hash = await walletClient.sendTransaction({
      account,
      chain,
      to: trade.to,
      data: trade.data,
      value: trade.value ?? 0n,
    });
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    if (receipt.status !== "success") throw new Error(`trader ${index} reverted: ${hash}`);

    results.push({
      index,
      address: account.address,
      hash,
      gasUsed: receipt.gasUsed.toString(),
    });
  }
}

await Promise.all(Array.from({ length: concurrency }, worker));
results.sort((left, right) => left.index - right.index);

await mkdir(resolve(root, "reports"), { recursive: true });
await writeFile(
  reportPath,
  `${JSON.stringify(
    {
      chainId: manifest.chainId,
      traderCount,
      successfulTransactions: results.length,
      transactions: results,
    },
    null,
    2,
  )}\n`,
);

console.log(`completed ${results.length} trader transactions; report: ${reportPath}`);
