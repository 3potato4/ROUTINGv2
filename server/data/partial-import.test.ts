import { clearCustomerData, getCustomerListItems, importWeeklyCustomersCsv } from "./customer-store.js";

const REF = new Date("2026-09-10T12:00:00");
const csv = `name,street 1 (Address - Street 1),City(Address - City),phone numbers,Delivery instructions(specific delivery instructions for that restaurant),Territory(Which Territory the restaurant is in)
Good Place,1 Main St,Philadelphia,Tom 215-555-9999,Side door,Philadelphia
Bad Place,2 Oak St,Media,Sam 610-555-0100,Front,`;

clearCustomerData();
const summary = await importWeeklyCustomersCsv(csv, REF, "partial.csv");
if (summary.customerCount !== 1) {
  throw new Error(`Expected 1 customer, got ${summary.customerCount}`);
}
if (summary.errors.length !== 1) {
  throw new Error(`Expected 1 row error, got ${summary.errors.length}`);
}
if (getCustomerListItems()[0]?.name !== "Good Place") {
  throw new Error("Customer list missing Good Place");
}

console.log("Partial import test passed.");
