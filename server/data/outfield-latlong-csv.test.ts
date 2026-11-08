import { readFileSync } from "fs";
import { parseCustomersCsv } from "./csv-parser.js";

const path =
  process.env.OUTFIELD_CSV ??
  "/Users/davidhall/Desktop/LAT AND LONG Outfield_Accounts 2.csv";

const text = readFileSync(path, "utf8");
const result = await parseCustomersCsv(text, new Date("2026-09-10T12:00:00"));

if (result.customers.length < 400) {
  throw new Error(`Expected ~429 customers, got ${result.customers.length}`);
}

const outfieldCsv = result.customers.filter((c) => c.coordinateSource === "outfield_csv");
if (outfieldCsv.length !== result.customers.length) {
  throw new Error(
    `Expected all loaded accounts to use CSV coords, got ${outfieldCsv.length}/${result.customers.length}`
  );
}

const sample = result.customers.find((c) => c.name === "3rd and Ferry");
if (!sample || sample.lat !== 40.6898772 || sample.lng !== -75.208699) {
  throw new Error(`3rd and Ferry coords mismatch: ${JSON.stringify(sample)}`);
}
if (sample.id !== "outfield-4412997") {
  throw new Error(`Expected Outfield account id in customer id, got ${sample.id}`);
}

console.log(`Outfield lat/long CSV test passed (${result.customers.length} accounts).`);
